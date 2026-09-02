namespace IzmirimCard.Api.DTOs
{
    public class RegisterDto
    {
        public string CardId { get; set; } = string.Empty;
        public string UserType { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty; 
    }

    public class LoginDto
    {
        public string Email { get; set; } = string.Empty; 
        public string Password { get; set; } = string.Empty; 
        public string ConnectionId { get; set; } = string.Empty;
    }

   
    public class ChangePasswordDto
    {
        public string OldPassword { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }

    public class VerifyEmailDto
    {
        public string Email { get; set; } = string.Empty;
        public string OtpCode { get; set; } = string.Empty;
    }

    public class ResendDto
    {
        public string Email { get; set; } = string.Empty;
    }

    public class ForgotPasswordDto
    {
        public string Email { get; set; } = string.Empty;
    }

    public class ResetPasswordDto
    {
        public string Email { get; set; } = string.Empty;
        public string OtpCode { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }
}