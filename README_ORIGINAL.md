# C# CRUD Web Application

A basic ASP.NET Core MVC web application demonstrating CRUD (Create, Read, Update, Delete) operations with Entity Framework and SQLite.

## Features

- **Product Management**: Complete CRUD operations for products
- **Responsive UI**: Bootstrap-styled interface that works on all devices
- **Form Validation**: Client and server-side validation
- **SQLite Database**: Lightweight, file-based database
- **Entity Framework Core**: Modern ORM for data access

## Technology Stack

- **Backend**: ASP.NET Core 8.0 MVC
- **Database**: SQLite with Entity Framework Core
- **Frontend**: HTML5, Bootstrap 5.3, jQuery
- **Validation**: ASP.NET Core Model Validation with jQuery Unobtrusive Validation

## Project Structure

```
CrudApp/
├── Controllers/
│   └── ProductsController.cs      # CRUD operations controller
├── Data/
│   └── ApplicationDbContext.cs    # Entity Framework context
├── Models/
│   └── Product.cs                 # Product data model with validation
├── Views/
│   ├── Products/
│   │   ├── Index.cshtml          # List all products
│   │   ├── Create.cshtml         # Create new product
│   │   ├── Edit.cshtml           # Edit existing product
│   │   ├── Details.cshtml        # View product details
│   │   └── Delete.cshtml         # Delete confirmation
│   ├── Shared/
│   │   ├── _Layout.cshtml        # Main layout template
│   │   └── _ValidationScriptsPartial.cshtml
│   ├── _ViewStart.cshtml
│   └── _ViewImports.cshtml
├── Migrations/                    # Entity Framework migrations
├── Program.cs                     # Application configuration and startup
├── CrudApp.csproj                # Project file with dependencies
└── appsettings.json              # Configuration settings
```

## Implementation Steps

### 1. Project Setup
- Created ASP.NET Core MVC project structure
- Configured `Program.cs` with MVC and Entity Framework services
- Set up `appsettings.json` with SQLite connection string
- Added Entity Framework NuGet packages to `CrudApp.csproj`

### 2. Data Model and Database
- Created `Product` model with validation attributes:
  - Required Name (max 100 characters)
  - Optional Description (max 500 characters) 
  - Required Price (must be > 0)
  - Required Quantity (must be >= 0)
  - Auto-generated CreatedAt timestamp
- Set up `ApplicationDbContext` for Entity Framework
- Created and applied initial database migration

### 3. Controller Implementation
- Built `ProductsController` with full CRUD operations:
  - `Index()` - List all products
  - `Details(id)` - Show single product
  - `Create()` - Display create form and handle POST
  - `Edit(id)` - Display edit form and handle POST
  - `Delete(id)` - Display delete confirmation and handle POST
- Implemented async/await patterns for database operations
- Added proper error handling and model validation

### 4. Views and UI
- Created responsive layout using Bootstrap 5.3
- Built comprehensive view templates:
  - Product listing with search-friendly table
  - Forms for create/edit with validation
  - Details view with clean layout
  - Delete confirmation with product summary
- Integrated client-side validation with jQuery
- Added navigation and user-friendly messaging

### 5. Database Setup
- Installed Entity Framework CLI tools
- Created initial migration for database schema
- Applied migration to create SQLite database
- Database automatically created as `app.db`

## Getting Started

### Prerequisites
- .NET 8.0 SDK or later
- Git (optional)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/peak-flow/csharp.git
   cd csharp
   ```

2. **Restore dependencies**
   ```bash
   dotnet restore
   ```

3. **Run the application**
   ```bash
   dotnet run
   ```

4. **Access the application**
   - Open your browser to `https://localhost:5001` or `http://localhost:5000`
   - The application will automatically redirect to the Products page

## Usage

### Managing Products

1. **View Products**: Navigate to the home page to see all products in a table
2. **Add Product**: Click "Create New Product" button and fill out the form
3. **Edit Product**: Click "Edit" button next to any product in the list
4. **View Details**: Click "Details" button to see full product information
5. **Delete Product**: Click "Delete" button and confirm the deletion

### Form Validation

The application includes comprehensive validation:
- **Name**: Required, maximum 100 characters
- **Description**: Optional, maximum 500 characters
- **Price**: Required, must be greater than 0
- **Quantity**: Required, must be 0 or greater

## Database

The application uses SQLite with the following schema:

**Products Table**
- `Id` (INTEGER, Primary Key, Auto-increment)
- `Name` (TEXT, Required, Max 100 chars)
- `Description` (TEXT, Optional, Max 500 chars)
- `Price` (DECIMAL, Required, > 0)
- `Quantity` (INTEGER, Required, >= 0)
- `CreatedAt` (DATETIME, Auto-generated)

## Development

### Adding New Features
1. Update the model in `Models/Product.cs`
2. Create and apply a new migration:
   ```bash
   dotnet ef migrations add YourMigrationName
   dotnet ef database update
   ```
3. Update controller actions as needed
4. Modify views to support new functionality

### Customization
- Modify Bootstrap classes in views for different styling
- Update validation rules in the Product model
- Add new controllers following the same pattern
- Extend the database context for additional entities

## License

This project is open source and available under the MIT License.