using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Api.Abstract.Repositories;
using Api.Abstract.Services;
using Api.DAL;
using Api.Repositories;
using Api.Services;

namespace Api
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();

            services.AddTransient<IDummyRepository, DummyRepository>();
            services.AddTransient<IDummyService, DummyService>();
            services.AddDbContext<DummyContext>(e =>
            {
                e.UseMySql(Environment.GetEnvironmentVariable("DB_CONNECTION_STRING"));
            });

            using var serviceScope = services.BuildServiceProvider().GetRequiredService<IServiceScopeFactory>()
                .CreateScope();
            DummyContext dummyContext = serviceScope.ServiceProvider.GetService<DummyContext>();
            dummyContext.Database.Migrate();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }
    }
}
