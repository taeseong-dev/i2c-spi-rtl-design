`timescale 1ns / 1ps

module top_spi_demo(

    input logic clk,
    input logic rst,
    input logic [07:00] sw,
    input logic btn_r,

    //master
    output logic m_sclk,
    output logic m_mosi,
    input  logic m_miso,
    output logic m_cs_n,

    //fnd
    output logic [03:00] fnd_digit,
    output logic [07:00] fnd_data

);

    logic [07:00] m_fnd_data;

    top_spi_master dut_spi_master_top(

    .clk(clk),
    .rst(rst),
    .sw(sw),
    .btn_r(btn_r),

    .m_fnd_data(m_fnd_data),

    .sclk(m_sclk),
    .mosi(m_mosi),
    .miso(m_miso),
    .cs_n(m_cs_n)
    );


    fnd_controller dut_fnd_cntl(

    .clk(clk),
    .rst(rst),
    .i_fnd_data({8'b0, m_fnd_data}),

    .o_fnd_digit(fnd_digit),
    .o_fnd_data(fnd_data)


    );

endmodule

