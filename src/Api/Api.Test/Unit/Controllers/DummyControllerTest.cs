using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using Api.Abstract.Services;
using Api.Controllers;
using Api.Models;

namespace Api.Test.Unit.Controllers
{
    [TestClass]
    public class DummyControllerTest
    {
        [TestMethod]
        public void Index_ReturnsExpectedData()
        {
            // Arrange
            DummyEntity[] data = {
                new DummyEntity {Name = "Some Name", Id = 1},
                new DummyEntity {Name = "Other Name", Id = 2}
            };

            Mock<IDummyService> dummyService = new Mock<IDummyService>();
            dummyService.Setup(e => e.FindAll()).Returns(data);

            DummyController dummyController = new DummyController(dummyService.Object);

            // Act
            IActionResult result = dummyController.Index();

            // Assert
            IEnumerable<DummyEntity> objectResult = (result as OkObjectResult)?.Value as IEnumerable<DummyEntity>;

            CollectionAssert.AreEqual(data, objectResult.ToList());
        }
    }
}
