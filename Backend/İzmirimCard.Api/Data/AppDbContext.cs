using IzmirimCard.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace IzmirimCard.Api.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Transaction> Transactions { get; set; }
        public DbSet<UserSession> UserSessions { get; set; }
    }
}