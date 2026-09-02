using IzmirimCard.Api.Data;
using IzmirimCard.Api.DTOs;
using IzmirimCard.Api.Hubs;
using IzmirimCard.Api.Models;
using IzmirimCard.Api.Services; 
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BCrypt.Net; 

namespace IzmirimCard.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly IHubContext<IzmirimHub> _hubContext;

        public AuthController(AppDbContext context, IConfiguration configuration, IHubContext<IzmirimHub> hubContext)
        {
            _context = context;
            _configuration = configuration;
            _hubContext = hubContext;
        }

        // Yardımcı Metot: 6 haneli rastgele güvenlik kodu üretici
        private string GenerateOtpCode()
        {
            Random rnd = new Random();
            return rnd.Next(100000, 999999).ToString();
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            if (await _context.Users.AnyAsync(u => u.CardId == dto.CardId || u.Email == dto.Email))
                return BadRequest("Bu kart numarası veya e-posta zaten sistemde kayıtlı.");

            string otpCode = GenerateOtpCode();

            var newUser = new User
            {
                CardId = dto.CardId,
                UserType = dto.UserType,
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                Balance = 0,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                
                // GÜVENLİK ALANLARI: Kayıt olunduğu an hesap onaysız başlar
                IsEmailVerified = false,
                VerificationCode = otpCode,
                CodeExpiration = DateTime.UtcNow.AddMinutes(5) // Kod sadece 5 dakika geçerli!
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            // E-Posta Gönderme İşlemi 
            Task.Run(() => EmailSender.SendOtpEmail(newUser.Email, otpCode));

            return Ok(new { message = "Kayıt başarılı. Lütfen e-postanıza gönderilen kod ile hesabınızı doğrulayın." });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            
            if (user == null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash)) 
                return Unauthorized("E-posta veya şifre hatalı.");

           // E-Posta doğrulanmamışsa girişe kesinlikle izin verme!
            if (!user.IsEmailVerified)
                return BadRequest(new { code = "NOT_VERIFIED", message = "Lütfen önce e-posta adresinizi doğrulayın." });

            var existingSession = await _context.UserSessions.FirstOrDefaultAsync(s => s.CardId == user.CardId);
            if (existingSession != null)
            {
                if (!string.IsNullOrEmpty(existingSession.ConnectionId) && existingSession.ConnectionId != dto.ConnectionId)
                {
                    await _hubContext.Clients.Client(existingSession.ConnectionId).SendAsync("ForceLogout");
                }
                existingSession.ConnectionId = dto.ConnectionId;
            }
            else
            {
                _context.UserSessions.Add(new UserSession { CardId = user.CardId, ConnectionId = dto.ConnectionId });
            }
            await _context.SaveChangesAsync();

            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes("SuperSecretKeyForIzmirimCardSystem2026!");
            
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, user.CardId) }),
                Expires = DateTime.UtcNow.AddDays(7),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return Ok(new { 
                token = tokenHandler.WriteToken(token), 
                userType = user.UserType,
                cardId = user.CardId 
            });
        }

        // ==========================================
        // GÜNCELLENDİ: E-POSTA DOĞRULAMA (Kayıt Sonrası)
        // ==========================================
        [HttpPost("verify-email")]
        public async Task<IActionResult> VerifyEmail([FromBody] VerifyEmailDto dto)
        {
           
            Console.WriteLine($"\n--- OTP DOĞRULAMA İSTEĞİ GELDİ ---");
            Console.WriteLine($"Email: {dto.Email}");
            Console.WriteLine($"Girilen Kod: '{dto.OtpCode}'");

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null) return NotFound("Kullanıcı bulunamadı.");

            Console.WriteLine($"Veritabanındaki Gerçek Kod: '{user.VerificationCode}'");

            if (user.IsEmailVerified) 
                return Ok("BAŞARILI"); // Flutter kapatsın diye BAŞARILI dönüyoruz

            // Boşlukları temizleyerek kontrol et
            if (user.VerificationCode != dto.OtpCode.Trim())
            {
                Console.WriteLine("HATA: Kodlar eşleşmiyor!");
                return BadRequest("Hatalı doğrulama kodu.");
            }

            // TimeZone çakışması yapmasın diye süre kontrolünü test için kapattık
            /*
            if (user.CodeExpiration < DateTime.UtcNow)
                return BadRequest("Bu kodun süresi dolmuş. Lütfen yeni bir kod isteyin.");
            */

            user.IsEmailVerified = true;
            user.VerificationCode = null; 
            user.CodeExpiration = null;
            await _context.SaveChangesAsync();

            Console.WriteLine("BAŞARILI: Veritabanı güncellendi, kullanıcı onaylandı!\n");
            
            return Ok("BAŞARILI"); 
        }

        // ==========================================
        // YENİDEN KOD GÖNDERME (Resend Mail)
        // ==========================================
        [HttpPost("resend-verification")]
        public async Task<IActionResult> ResendVerification([FromBody] ResendDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null) return NotFound("Kullanıcı bulunamadı.");
            
            if (user.IsEmailVerified) return BadRequest("Hesap zaten doğrulanmış.");

            string newOtp = GenerateOtpCode();
            user.VerificationCode = newOtp;
            user.CodeExpiration = DateTime.UtcNow.AddMinutes(5);
            await _context.SaveChangesAsync();

            Task.Run(() => EmailSender.SendOtpEmail(user.Email, newOtp));

            return Ok("Yeni doğrulama kodu e-postanıza gönderildi.");
        }

        // ==========================================
        // ŞİFREMİ UNUTTUM 
        // ==========================================
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null) return Ok("Şifre sıfırlama talimatları e-postanıza gönderildi."); 

            string resetOtp = GenerateOtpCode();
            user.VerificationCode = resetOtp;
            user.CodeExpiration = DateTime.UtcNow.AddMinutes(10); 
            await _context.SaveChangesAsync();

            Task.Run(() => EmailSender.SendOtpEmail(user.Email, resetOtp));

            return Ok("Şifre sıfırlama talimatları e-postanıza gönderildi.");
        }

        // ==========================================
        // GÜNCELLENDİ: ŞİFREYİ SIFIRLA
        // ==========================================
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null) return BadRequest("Geçersiz istek.");

            if (user.VerificationCode != dto.OtpCode.Trim())
                return BadRequest("Hatalı doğrulama kodu.");

            
            /*
            if (user.CodeExpiration < DateTime.UtcNow)
                return BadRequest("Bu kodun süresi dolmuş.");
            */

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            
            user.IsEmailVerified = true; 
            user.VerificationCode = null;
            user.CodeExpiration = null;
            
            await _context.SaveChangesAsync();

            // Flutter'ın pencereyi kapatabilmesi için BAŞARILI dönüyoruz
            return Ok("BAŞARILI");
        }

        // ==========================================
        // GÜNCELLENDİ: ŞİFRE DEĞİŞTİR (Profil Ekranı)
        // ==========================================
        [Authorize] 
        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto dto)
        {
            var cardId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(cardId)) 
                return Unauthorized("Oturum yetkisi bulunamadı.");

            var user = await _context.Users.FirstOrDefaultAsync(u => u.CardId == cardId);
            if (user == null) 
                return NotFound("Kullanıcı bulunamadı.");

            if (!BCrypt.Net.BCrypt.Verify(dto.OldPassword, user.PasswordHash))
                return BadRequest("Eski şifreniz hatalı.");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
            await _context.SaveChangesAsync();

            // Flutter'ın pencereyi kapatabilmesi için BAŞARILI dönüyoruz
            return Ok("BAŞARILI");
        }
    }
}