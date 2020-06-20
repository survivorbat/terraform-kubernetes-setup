using System.Collections.Generic;
using Api.Abstract.Repositories;
using Api.DAL;
using Api.Models;

namespace Api.Repositories
{
    public class DummyRepository : IDummyRepository
    {
        private readonly DummyContext _context;

        public DummyRepository(DummyContext context)
        {
            _context = context;
        }

        public IEnumerable<DummyEntity> FindAll()
        {
            return _context.DummyEntities;
        }
    }
}
