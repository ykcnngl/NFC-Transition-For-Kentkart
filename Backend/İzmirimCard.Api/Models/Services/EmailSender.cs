using System.Net;
using System.Net.Mail;

namespace IzmirimCard.Api.Services
{
    public class EmailSender
    {
        // GMAIL HESAP BİLGİLERİN 
        private const string SenderEmail = "ycananoglu@gmail.com";
        private const string AppPassword = "Şifre"; // Gmail'den alacağın 16 haneli kod

        public static void SendOtpEmail(string toEmail, string otpCode)
        {
            var fromAddress = new MailAddress(SenderEmail, "İzmirim Kart Destek");
            var toAddress = new MailAddress(toEmail);

           var smtp = new SmtpClient
            {
                Host = "smtp.gmail.com",
                Port = 587,
                EnableSsl = true,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                
                UseDefaultCredentials = false, 
                Credentials = new NetworkCredential(fromAddress.Address, AppPassword)
            };

            using var message = new MailMessage(fromAddress, toAddress)
            {
                Subject = "İzmirim Kart - Güvenlik Doğrulama Kodu",
                Body = $@"
Merhaba,

İzmirim Kart uygulamanız için güvenlik doğrulama kodunuz aşağıdadır:

Güvenlik Kodu: {otpCode}

Bu kod 3 dakika boyunca geçerlidir. Lütfen bu kodu kimseyle paylaşmayın.
",
                IsBodyHtml = false
            };

            try
            {
                smtp.Send(message);
                Console.WriteLine($"\n[BAŞARILI] {toEmail} adresine OTP kodu gönderildi.\n");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"\n[HATA] E-posta gönderilemedi! Sebebi: {ex.Message}\n");
            }
        }
    }
}