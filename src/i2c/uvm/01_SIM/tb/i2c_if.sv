interface i2c_if(input logic clk, input logic rst);


	logic 			cmd_start;
	logic 			cmd_write;
	logic 			cmd_read;
	logic 			cmd_stop;

	logic	[07:00] tx_data;
	logic 	[07:00] rx_data;
	logic 			ack_in;
	logic 			ack_out;
	logic 			done;
	logic 			busy;

	logic 	[07:00] slave_data;
	logic 			slave_done;

	logic 			scl;
	wand 			sda;


	clocking drv_cb @(posedge clk);
		default input #1step output #0;
		input done;
		input busy;
		input rx_data;
		input ack_out;

		output cmd_start;
		output cmd_write;
		output cmd_read;
		output cmd_stop;
		output tx_data;
		output ack_in;

	endclocking

	clocking mon_cb @(posedge clk);
		default input #1step;
	
		input cmd_start;
		input cmd_write;
		input cmd_read;
		input cmd_stop;
	
		input tx_data;
		input rx_data;
		input ack_in;
		input ack_out;
		input done;
		input busy;
	
		input slave_data;
		input slave_done;
	
		input scl;
		input sda;
	endclocking

endinterface
