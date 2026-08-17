interface spi_if(input logic clk, input logic rst);


	logic			cpol;
	logic			cpha;
	logic [07:00]	clk_div;

	logic			start;
	logic [07:00]	tx_data;
	logic [07:00]	rx_data;
	logic			done;
	logic			busy;

	logic			sclk;
	logic			mosi;
	logic			miso;
	logic			cs_n;

	logic [07:00]	miso_data;


	clocking drv_cb @(posedge clk);
		default input #1step output #0;

		input done;
		input busy;
		input rx_data;

		output cpol;
		output cpha;
		output clk_div;

		output start;
		output tx_data;
		output miso_data;
	endclocking

	clocking mon_cb @(posedge clk);
		default input #1step;

		input cpol;
		input cpha;
		input clk_div;

		input start;
		input tx_data;
		input miso_data;

		input done;
		input busy;
		input rx_data;

		input sclk;
		input mosi;
		input miso;
		input cs_n;
	endclocking

endinterface
