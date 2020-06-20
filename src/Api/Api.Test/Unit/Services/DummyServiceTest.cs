using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using Api.Abstract.Repositories;
using Api.Abstract.Services;
using Api.Models;
using Api.Services;

namespace Api.Test.Unit.Services
{
    [TestClass]
    public class DummyServiceTest
    {
        [TestMethod]
        public void FindAll_ReturnsExpectedData()
        {
            // Arrange
            DummyEntity[] data = {
                new DummyEntity {Name = "Some Name", Id = 1},
                new DummyEntity {Name = "Other Name", Id = 2}
            };

            Mock<IDummyRepository> dummyRepository = new Mock<IDummyRepository>();
            dummyRepository.Setup(e => e.FindAll()).Returns(data);

            IDummyService service = new DummyService(dummyRepository.Object);

            // Act
            IEnumerable<DummyEntity> result = service.FindAll();

            // Assert
            CollectionAssert.AreEqual(data, result.ToArray());
        }
    }
}
