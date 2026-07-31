`timescale 1ns / 1ps

module i2c_master_top (
    input logic clk,
    input logic rst,

    input logic         start,
    input logic [07:00] sw,
    input logic         sw_read, // 0 : write, 1 : read

    output logic [07:00] rx_data_reg,

    output logic scl,
    inout  wire  sda
);

    typedef enum logic [02:00] {
        IDLE,
        START,
        ADDR,
        DATA,
        STOP
    } i2c_state_e;

    localparam SLA_W = {7'h12, 1'b0};
    localparam SLA_R = {7'h12, 1'b1};
    i2c_state_e         state;


    logic               cmd_start;
    logic               cmd_write;
    logic               cmd_read;
    logic               cmd_stop;
    logic       [07:00] tx_data;
    logic               ack_in;

    logic       [07:00] sw_data;
    logic               sw_read_data;
    logic       [01:00] cnt;


    logic       [07:00] rx_data;
    logic               done;
    logic               ack_out;
    logic               busy;

    I2C_Master U_I2C_MASTER (

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


    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            cmd_start    <= 1'b0;
            cmd_write    <= 1'b0;
            cmd_read     <= 1'b0;
            cmd_stop     <= 1'b0;
            tx_data      <= 0;
            sw_data      <= 0;
            cnt          <= 0;
            ack_in       <= 0;
            sw_read_data <= 0;
            rx_data_reg  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    cmd_start <= 1'b0;
                    cmd_write <= 1'b0;
                    cmd_read  <= 1'b0;
                    cmd_stop  <= 1'b0;
                    if (start) begin
                        state        <= START;
                        sw_data      <= sw;
                        cmd_start    <= 1'b1;
                        sw_read_data <= sw_read;
                    end
                end
                START: begin
                    cmd_start <= 1'b0;
                    cmd_write <= 1'b0;
                    cmd_read  <= 1'b0;
                    cmd_stop  <= 1'b0;
                    if (done) begin
                        state     <= ADDR;
                        cmd_write <= 1'b1;
                        cmd_read  <= 1'b0;
                        if (sw_read_data) begin
                            tx_data <= SLA_R;
                        end else begin
                            tx_data <= SLA_W;
                        end
                    end
                end
                ADDR: begin
                    cmd_start <= 1'b0;
                    cmd_write <= 1'b0;
                    cmd_read  <= 1'b0;
                    cmd_stop  <= 1'b0;
                    if (done) begin
                        state <= DATA;
                        if (sw_read_data) begin
                            cmd_read <= 1'b1;
                            ack_in   <= 1'b1;
                        end else begin
                            cmd_write <= 1'b1;
                            tx_data   <= sw_data[07:00];
                        end
                    end
                end
                DATA: begin

                    cmd_start <= 1'b0;
                    cmd_write <= 1'b0;
                    cmd_read  <= 1'b0;
                    cmd_stop  <= 1'b0;
                    if (done) begin
                        state <= STOP;
                        cnt <= 0;
                        cmd_stop <= 1'b1;
                        ack_in <= 1'b0;
                        rx_data_reg <= rx_data;
                    end

                end

                STOP: begin
                    cmd_start <= 1'b0;
                    cmd_write <= 1'b0;
                    cmd_read  <= 1'b0;
                    cmd_stop  <= 1'b0;
                    if (done) begin
                        state <= IDLE;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end



endmodule
