`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/16 17:58:45
// Design Name: 
// Module Name: top_spi_slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_spi_slave(
    input logic clk,
    input logic rst,
    input logic s_sclk,
    input logic s_cs_n,
    input logic s_mosi,

    output logic s_miso,
    output logic [03:00] fnd_digit,
    output logic [07:00] fnd_data
    );

    logic [07:00] rx_data;

    spi_slave dut_slave(

        .clk(clk),
        .rst(rst),

        .sclk(s_sclk),
        .cs(s_cs_n),
        .mosi(s_mosi),

        .miso(s_miso),
        .busy(),
        .done(),
        .rx_data(rx_data)
    );

    fnd_controller dut_fnd_cntl(

    .clk(clk),
    .rst(rst),
    .i_fnd_data({8'b0, rx_data}),

    .o_fnd_digit(fnd_digit),
    .o_fnd_data(fnd_data)
    );




endmodule
