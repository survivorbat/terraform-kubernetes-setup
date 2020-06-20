using Microsoft.EntityFrameworkCore;
using Api.DAL;

namespace Api.Test
{
    public class TestHelpers
    {
        /// <summary>
        /// Inject test data
        /// </summary>
        internal static void InjectData<T>(DbContextOptions<DummyContext> options, params T[] entities)
            where T : class
        {
            using DummyContext context = new DummyContext(options);
            context.Set<T>().AddRange(entities);
            context.SaveChanges();
        }
    }
}
