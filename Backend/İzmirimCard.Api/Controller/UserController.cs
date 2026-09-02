using IzmirimCard.Api.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http; 
using Microsoft.AspNetCore.Hosting; 
using System.IO; 
using System.Threading.Tasks;
using System;

namespace IzmirimCard.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IWebHostEnvironment _env; 

        public UserController(AppDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        [Authorize] 
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile([FromQuery] string cardId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.CardId == cardId);
            
            if (user == null) 
                return NotFound(new { message = "Kullanıcı bulunamadı." });

            return Ok(new
            {
                firstName = user.FirstName,
                lastName = user.LastName,
                email = user.Email,
                userType = user.UserType,
                cardId = user.CardId,
                profileImageUrl = user.ProfileImageUrl 
            });
        }

        // ==========================================
        // YENİ: PROFİL FOTOĞRAFI YÜKLEME METODU
        // ==========================================
        [Authorize]
        [HttpPost] 
        [Route("/api/User/upload-profile-image")] // Sabit rotayı buraya ekledik ki Swagger kesin görsün
        public async Task<IActionResult> UploadProfileImage([FromForm] IFormFile image, [FromForm] string cardId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.CardId == cardId);
            if (user == null) 
                return NotFound(new { message = "Kullanıcı bulunamadı." });

            if (image == null || image.Length == 0) 
                return BadRequest(new { message = "Geçersiz dosya veya dosya seçilmedi." });

            string webRootPath = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            string uploadsFolder = Path.Combine(webRootPath, "uploads");
            
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            string uniqueFileName = Guid.NewGuid().ToString() + "_" + Path.GetFileName(image.FileName);
            string filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await image.CopyToAsync(stream);
            }

            string requestUrl = $"{Request.Scheme}://{Request.Host}";
            string fullImageUrl = $"{requestUrl}/uploads/{uniqueFileName}";

            user.ProfileImageUrl = fullImageUrl;
            await _context.SaveChangesAsync();

            return Ok(new { success = true, profileImageUrl = fullImageUrl });
        }
    }
}