interface spi_if(input logic clk, input logic rst);


	logic			start;
	logic [07:00]	tx_data;
	logic [07:00]	rx_data;
	logic			done;
	logic			busy;

	logic			sclk;
	logic			mosi;
	logic			miso;
	logic			cs_n;

	logic			slv_done;
	logic [07:00]	slv_rx_data;


	clocking drv_cb @(posedge clk);
		default input #1step output #0;

		input  done;
		input  busy;
		input  rx_data;

		output start;
		output tx_data;
	endclocking

	clocking mon_cb @(posedge clk);
		default input #1step;

		input start;
		input tx_data;

		input done;
		input busy;
		input rx_data;

		input sclk;
		input mosi;
		input miso;
		input cs_n;

		input slv_done;
		input slv_rx_data;
	endclocking

endinterface
