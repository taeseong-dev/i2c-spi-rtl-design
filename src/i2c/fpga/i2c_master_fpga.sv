`timescale 1ns / 1ps

module i2c_master_fpga (

    input logic clk,
    input logic rst,

    input logic         btn_r,
    input logic [07:00] sw,
    input logic         sw_read,

    output logic [03:00] fnd_digit,
    output logic [07:00] fnd_data,

    //master
    inout  wire  m_sda,
    output logic m_scl

);

    logic w_dbc_start;
    logic [07:00] rx_data_reg;

    btn_debounce dut_btn_dbc (

        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_r),

        .o_btn(w_dbc_start)

    );

    i2c_master_top u_i2c_master_top (
        .clk(clk),
        .rst(rst),

        .start(w_dbc_start),
        .sw(sw),
        .sw_read(sw_read),

        .rx_data_reg(rx_data_reg),

        .scl(m_scl),
        .sda(m_sda)
    );

    fnd_controller dut_fnd_cntl (

        .clk(clk),
        .rst(rst),
        .i_fnd_data({8'b0, rx_data_reg}),

        .o_fnd_digit(fnd_digit),
        .o_fnd_data (fnd_data)
    );


endmodule
