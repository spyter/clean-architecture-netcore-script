#drop this script in the folder you want to initialize
#feel free to modify whatever makes sense
#this script will stub out the basics (sln, projects, dependencies, nuget packages)
#it makes some opinionated assumptions on frameworks such as: efcore, moq/xunit, automapper & fluent validations
#it also preps the services for ef migrations (in the infrastructure projects)
#this could be written better. Ultimately it was just a quick hack, but it's useful, and I thought I'd share w/anyone who's interested

$solution = "MySolution" #name of solution
$services = @("Admin", "Analytics", "Commerce") #names of micro services/domains

###### ONLY CHANGE BELOW THIS LINE IF YOU WANT TO CUSTOMIZE THINGS ######

"dotnet new sln -n $solution" | Invoke-Expression

function GenerateService {
  param ($s, $api)

  "dotnet new $api -n $solution.$s.Api" | Invoke-Expression
  "dotnet sln $solution.sln add $solution.$s.Api\$solution.$s.Api.csproj" | Invoke-Expression
  "dotnet new classlib -n $solution.$s.Application" | Invoke-Expression
  "dotnet sln $solution.sln add $solution.$s.Application\$solution.$s.Application.csproj" | Invoke-Expression
  "dotnet new classlib -n $solution.$s.Infrastructure" | Invoke-Expression
  "dotnet sln $solution.sln add $solution.$s.Infrastructure\$solution.$s.Infrastructure.csproj" | Invoke-Expression
  "dotnet new classlib -n $solution.$s.Domain" | Invoke-Expression
  "dotnet sln $solution.sln add $solution.$s.Domain\$solution.$s.Domain.csproj" | Invoke-Expression
  "dotnet new classlib -n $solution.$s.Tests" | Invoke-Expression
  "dotnet sln $solution.sln add $solution.$s.Tests\$solution.$s.Tests.csproj" | Invoke-Expression

  "dotnet add $solution.$s.Api\$solution.$s.Api.csproj reference $solution.$s.Application\$solution.$s.Application.csproj" | Invoke-Expression
  "dotnet add $solution.$s.Api\$solution.$s.Api.csproj reference $solution.$s.Infrastructure\$solution.$s.Infrastructure.csproj" | Invoke-Expression
  "dotnet add $solution.$s.Application\$solution.$s.Application.csproj reference $solution.$s.Domain\$solution.$s.Domain.csproj" | Invoke-Expression
  "dotnet add $solution.$s.Infrastructure\$solution.$s.Infrastructure.csproj reference $solution.$s.Application\$solution.$s.Application.csproj" | Invoke-Expression
  "dotnet add $solution.$s.Tests\$solution.$s.Tests.csproj reference $solution.$s.Api\$solution.$s.Api.csproj" | Invoke-Expression
  "dotnet add $solution.$s.Tests\$solution.$s.Tests.csproj reference $solution.$s.Application\$solution.$s.Application.csproj" | Invoke-Expression
  "dotnet add $solution.$s.Tests\$solution.$s.Tests.csproj reference $solution.$s.Infrastructure\$solution.$s.Infrastructure.csproj" | Invoke-Expression
  "dotnet add $solution.$s.Tests\$solution.$s.Tests.csproj reference $solution.$s.Domain\$solution.$s.Domain.csproj" | Invoke-Expression

  "dotnet add $solution.$s.Api\$solution.$s.Api.csproj package Microsoft.EntityFrameworkCore.Design"

  "dotnet add $solution.$s.Infrastructure\$solution.$s.Infrastructure.csproj package Microsoft.EntityFrameworkCore"
  "dotnet add $solution.$s.Infrastructure\$solution.$s.Infrastructure.csproj package Microsoft.EntityFrameworkCore.SqlServer"
  "dotnet add $solution.$s.Infrastructure\$solution.$s.Infrastructure.csproj package Microsoft.EntityFrameworkCore.Tools"

  "dotnet add $solution.$s.Application\$solution.$s.Application.csproj package AutoMapper"
  "dotnet add $solution.$s.Application\$solution.$s.Application.csproj package AutoMapper.Extensions.Microsoft.DependencyInjection"
  "dotnet add $solution.$s.Application\$solution.$s.Application.csproj package FluentValidation"
  "dotnet add $solution.$s.Application\$solution.$s.Application.csproj package FluentValidation.DependencyInjectionExtensions"

  "dotnet add $solution.$s.Tests\$solution.$s.Tests.csproj package Moq"
  "dotnet add $solution.$s.Tests\$solution.$s.Tests.csproj package xunit"
}

foreach ($s in $services) {
  GenerateService -s $s -api "webapi"
}

GenerateService -s "Shared" -api "classlib"

"dotnet build" | Invoke-Expression
