using System.Diagnostics.CodeAnalysis;
using Microsoft.EntityFrameworkCore;
using Api.Models;

namespace Api.DAL
{
    [ExcludeFromCodeCoverage]
    public class DummyContext : DbContext
    {
        public DummyContext()
        {
        }

        public DummyContext(DbContextOptions<DummyContext> options): base(options)
        {
        }

        public DbSet<DummyEntity> DummyEntities { get; set; }
    }
}
