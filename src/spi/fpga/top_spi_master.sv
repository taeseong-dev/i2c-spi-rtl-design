`timescale 1ns / 1ps
module top_spi_master (

    input logic         clk,
    input logic         rst,
    input logic [07:00] sw,
    input logic         btn_r,

    output logic [07:00] m_fnd_data,

    output logic sclk,
    output logic mosi,
    input  logic miso,
    output logic cs_n
);

    logic [07:00] sw_reg;
    logic [07:00] tx_reg;
    logic         start;
    logic         w_dbc_start;
    logic         done;
    logic [07:00] m_fnd_data_temp;
    logic [07:00] rx_data;

    btn_debounce dut_btn_dbc (

        .clk  (clk),
        .rst  (rst),
        .i_btn(btn_r),

        .o_btn(w_dbc_start)
    );

    spi_master DUT_SPI_MASTER (
        .clk(clk),
        .rst(rst),
        .cpol(0),  // idle 0 : LOW, 1 : HIGH
        .cpha(0),  // 
        .clk_div(100),
        .tx_data(tx_reg),
        .start(start),
        .rx_data(rx_data),
        .done(done),
        .busy(),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n)
    );


    typedef enum logic [01:00] {
        IDLE,
        START,
        DATA
    } state_e;

    state_e state;



    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sw_reg <= 0;
            start <= 0;
            state <= IDLE;
            m_fnd_data_temp <= 0;
            m_fnd_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    sw_reg <= 0;
                    state  <= IDLE;
                    if (w_dbc_start) begin
                        state  <= START;
                        sw_reg <= sw;
                    end
                end
                START: begin
                    tx_reg <= sw_reg;
                    start  <= 1'b1;
                    state  <= DATA;
                end
                DATA: begin
                    start <= 1'b0;
                    if (done) begin
                        state <= IDLE;
                        m_fnd_data <= rx_data;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end


endmodule
