`timescale 1ns / 1ps


module i2c_slave_fpga (

    input logic clk,
    input logic rst,

    input logic s_scl,
    inout logic s_sda,

    output logic [03:00] fnd_digit,
    output logic [07:00] fnd_data

);


    logic [07:00] rx_data;
    logic done;
    logic [07:00] fnd_data_reg;
    logic bit_sel;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fnd_data_reg <= 0;
        end else if (done) begin
            fnd_data_reg <= rx_data;
        end else begin
            fnd_data_reg <= fnd_data_reg;
        end
    end

    I2C_Slave u_i2c_slave (
        .clk(clk),
        .rst(rst),

        .done(done),
        .rx_data(rx_data),

        .scl(s_scl),
        .sda(s_sda)
    );

    fnd_controller dut_fnd_cntl (

        .clk(clk),
        .rst(rst),
        .i_fnd_data({8'b0, fnd_data_reg}),

        .o_fnd_digit(fnd_digit),
        .o_fnd_data (fnd_data)
    );



endmodule
