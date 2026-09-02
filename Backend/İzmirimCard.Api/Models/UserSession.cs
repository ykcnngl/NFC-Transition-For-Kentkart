using System.ComponentModel.DataAnnotations;

namespace IzmirimCard.Api.Models
{
    public class UserSession
    {
        [Key]
        public string CardId { get; set; } = string.Empty;
        public string ConnectionId { get; set; } = string.Empty; // SignalR bağlantı kimliği
    }
}