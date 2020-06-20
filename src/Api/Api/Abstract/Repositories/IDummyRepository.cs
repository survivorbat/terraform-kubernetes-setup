using System.Collections.Generic;
using Api.Models;

namespace Api.Abstract.Repositories
{
    public interface IDummyRepository
    {
        public IEnumerable<DummyEntity> FindAll();
    }
}
