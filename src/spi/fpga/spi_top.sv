`timescale 1ns / 1ps

module spi_top (

    input logic clk,
    input logic rst,
    input logic [07:00] tx_data,
    input logic start,


    output logic sclk,
    output logic mosi,
    output logic miso,
    output logic cs_n,

    output logic [07:00] rx_data,
    output logic done,
    output logic busy,

    output logic slv_busy,
    output logic slv_done,
    output logic [07:00] slv_rx_data
);



    spi_master U_SPI_MASTER (
        .clk    (clk),
        .rst    (rst),
        .cpol   (1'b0),     // idle 0 : LOW, 1 : HIGH
        .cpha   (1'b0),     // 
        .clk_div(8'd4),
        .tx_data(tx_data),
        .start  (start),
        .rx_data(rx_data),
        .done   (done),
        .busy   (busy),
        .sclk   (sclk),
        .mosi   (mosi),
        .miso   (miso),
        .cs_n   (cs_n)
    );

    spi_slave U_SPI_SLAVE (

        .clk(clk),
        .rst(rst),

        .sclk(sclk),
        .cs  (cs_n),
        .mosi(mosi),

        .miso(miso),
        .busy(slv_busy),
        .done(slv_done),
        .rx_data(slv_rx_data)
    );

endmodule
