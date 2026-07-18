`timescale 1ns / 1ps

module i2c_top (

    input logic         clk,
    input logic         rst,
    input logic         cmd_start,
    input logic         cmd_write,
    input logic         cmd_read,
    input logic         cmd_stop,
    input logic [07:00] tx_data,
    input logic         ack_in,

    output logic [07:00] rx_data,
    output logic         done,
    output logic         ack_out,
    output logic         busy,

    output logic [07:00] slave_data,
    output logic         slave_done,

    output logic scl,
    inout  tri1  sda
);

    pullup (sda);

    I2C_Master dut_i2c_master (
        .clk(clk),
        .rst(rst),

        .cmd_start(cmd_start),
        .cmd_write(cmd_write),
        .cmd_read (cmd_read),
        .cmd_stop (cmd_stop),
        .tx_data  (tx_data),
        .ack_in   (ack_in),

        .rx_data(rx_data),
        .done   (done),
        .ack_out(ack_out),
        .busy   (busy),

        .scl(scl),
        .sda(sda)
    );

    I2C_Slave dut_i2c_slave (
        .clk(clk),
        .rst(rst),

        .done   (slave_done),
        .rx_data(slave_data),

        .scl(scl),
        .sda(sda)
    );

endmodule
