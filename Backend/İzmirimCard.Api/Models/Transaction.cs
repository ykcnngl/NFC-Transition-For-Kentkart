using System.ComponentModel.DataAnnotations;

namespace IzmirimCard.Api.Models
{
    public class Transaction
    {
        [Key]
        public int Id { get; set; }
        public string CardId { get; set; } = string.Empty;
        public double Amount { get; set; }
        public string TransactionType { get; set; } = string.Empty; // "PASS" veya "TOPUP"
        public DateTime Date { get; set; } = DateTime.UtcNow;
    }
}