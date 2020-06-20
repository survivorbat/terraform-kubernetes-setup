using System.Collections.Generic;
using Api.Models;

namespace Api.Abstract.Services
{
    public interface IDummyService
    {
        public IEnumerable<DummyEntity> FindAll();
    }
}
