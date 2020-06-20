using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Api.Abstract.Services;
using Api.Models;

namespace Api.Controllers
{
    [ApiController]
    [Route("/api")]
    public class DummyController : ControllerBase
    {
        private readonly IDummyService _dummyService;

        public DummyController(IDummyService dummyService)
        {
            _dummyService = dummyService;
        }

        public IActionResult Index()
        {
            return Ok(_dummyService.FindAll());
        }
    }
}
