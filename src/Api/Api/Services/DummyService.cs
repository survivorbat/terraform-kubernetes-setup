using System.Collections.Generic;
using Api.Abstract.Repositories;
using Api.Abstract.Services;
using Api.Models;

namespace Api.Services
{
    public class DummyService : IDummyService
    {
        private readonly IDummyRepository _dummyRepository;

        public DummyService(IDummyRepository dummyRepository)
        {
            _dummyRepository = dummyRepository;
        }

        public IEnumerable<DummyEntity> FindAll()
        {
            return _dummyRepository.FindAll();
        }
    }
}
