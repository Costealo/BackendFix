using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Costealo.API.Migrations
{
    /// <inheritdoc />
    public partial class AddPlainPasswordAndSecurityCode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PlainPassword",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "SecurityCode",
                table: "Subscriptions",
                type: "nvarchar(4)",
                maxLength: 4,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PlainPassword",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "SecurityCode",
                table: "Subscriptions");
        }
    }
}
