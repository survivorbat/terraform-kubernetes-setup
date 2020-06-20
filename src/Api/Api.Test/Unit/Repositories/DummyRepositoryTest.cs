using System.Collections.Generic;
using System.Linq;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Api.Abstract.Repositories;
using Api.DAL;
using Api.Models;
using Api.Repositories;

namespace Api.Test.Unit.Repositories
{
    [TestClass]
    public class DummyRepositoryTest
    {
        private static SqliteConnection _connection;
        private static DbContextOptions<DummyContext> _options;

        [ClassInitialize]
        public static void ClassInitialize(TestContext ctx)
        {
            _connection = new SqliteConnection("DataSource=:memory:");
            _connection.Open();

            _options = new DbContextOptionsBuilder<DummyContext>()
                .UseSqlite(_connection)
                .Options;

            using DummyContext context = new DummyContext(_options);
            context.Database.EnsureCreated();
        }

        [ClassCleanup]
        public static void ClassCleanup()
        {
            _connection.Close();
        }

        [TestCleanup]
        public void TestCleanup()
        {
            using DummyContext context = new DummyContext(_options);
            context.DummyEntities.RemoveRange(context.DummyEntities);
            context.SaveChanges();
        }

        [TestMethod]
        public void FindAll_ReturnsEmptyListOnNoDummies()
        {
            // Arrange
            using DummyContext context = new DummyContext(_options);
            IDummyRepository dummyRepository = new DummyRepository(context);

            // Act
            IEnumerable<DummyEntity> result = dummyRepository.FindAll();

            // Assert
            Assert.AreEqual(0, result.Count());
        }

        [TestMethod]
        public void FindAll_ReturnsExpectedData()
        {
            // Arrange
            DummyEntity[] data = {
                new DummyEntity {Name = "Some Name", Id = 1},
                new DummyEntity {Name = "Other Name", Id = 2}
            };

            TestHelpers.InjectData(_options, data);

            using DummyContext context = new DummyContext(_options);
            IDummyRepository dummyRepository = new DummyRepository(context);

            // Act
            IEnumerable<DummyEntity> result = dummyRepository.FindAll().ToList();

            // Assert
            Assert.AreEqual(2, result.Count());
            Assert.AreEqual("Some Name", result.First().Name);
            Assert.AreEqual("Other Name", result.Last().Name);
        }
    }
}
