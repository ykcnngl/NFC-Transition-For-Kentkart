using System.ComponentModel.DataAnnotations;

namespace IzmirimCard.Api.Models
{
    public class User
    {
        [Key]
        public string CardId { get; set; } = string.Empty;
        
        // Yeni Eklenen Kişisel Bilgiler
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? ProfileImageUrl { get; set; }

        
        public string UserType { get; set; } = "Tam"; // Tam, Öğrenci, Öğretmen, Emekli
        public double Balance { get; set; } = 0.0;

        public string PasswordHash { get; set; }

        public bool IsEmailVerified { get; set; } = false;
        public string? VerificationCode { get; set; } 

        public DateTime? CodeExpiration { get; set; } 
    }
}