using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Costealo.API.Migrations
{
    /// <inheritdoc />
    public partial class AddManualItemFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_WorkbookItems_PriceItems_PriceItemId",
                table: "WorkbookItems");

            migrationBuilder.AlterColumn<int>(
                name: "PriceItemId",
                table: "WorkbookItems",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<string>(
                name: "ManualItemName",
                table: "WorkbookItems",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "ManualItemPrice",
                table: "WorkbookItems",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_WorkbookItems_PriceItems_PriceItemId",
                table: "WorkbookItems",
                column: "PriceItemId",
                principalTable: "PriceItems",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_WorkbookItems_PriceItems_PriceItemId",
                table: "WorkbookItems");

            migrationBuilder.DropColumn(
                name: "ManualItemName",
                table: "WorkbookItems");

            migrationBuilder.DropColumn(
                name: "ManualItemPrice",
                table: "WorkbookItems");

            migrationBuilder.AlterColumn<int>(
                name: "PriceItemId",
                table: "WorkbookItems",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_WorkbookItems_PriceItems_PriceItemId",
                table: "WorkbookItems",
                column: "PriceItemId",
                principalTable: "PriceItems",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
