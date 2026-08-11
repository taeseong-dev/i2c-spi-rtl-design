import uvm_pkg::*;
`include "uvm_macros.svh"

`include "i2c_if.sv"
`include "i2c_item.sv"
`include "i2c_sequence.sv"
`include "i2c_driver.sv"
`include "i2c_cmd_monitor.sv"
`include "i2c_cmd_agent.sv"
`include "i2c_bus_monitor.sv"
`include "i2c_bus_agent.sv"
`include "i2c_scoreboard.sv"
`include "i2c_coverage.sv"
`include "i2c_env.sv"
`include "i2c_test.sv"

module tb_i2c_uvm();

	logic clk;
	logic rst;

	always #5 clk =~ clk;

	initial begin
		clk = 0;
		rst = 1;
		repeat (3) @(posedge clk);
		rst = 0;
		@(posedge clk);
	end

	i2c_if vif(clk,rst);


	i2c_top dut(

	.clk				(clk			),
	.rst				(rst			),
	.cmd_start			(vif.cmd_start	),
	.cmd_write			(vif.cmd_write	),
	.cmd_read			(vif.cmd_read	),
	.cmd_stop			(vif.cmd_stop	),
	.tx_data			(vif.tx_data	),
	.ack_in				(vif.ack_in		),

	.rx_data			(vif.rx_data	),
	.done				(vif.done		),
	.ack_out			(vif.ack_out	),
	.busy				(vif.busy		),
                		                
	.slave_data			(vif.slave_data	),
	.slave_done			(vif.slave_done	),
                		                
	.scl				(vif.scl		),
	.sda				(vif.sda		)
);


	initial begin
		uvm_config_db#(virtual i2c_if)::set(null, "*", "vif", vif);
		run_test();
	end

	initial begin
		$fsdbDumpfile("novas.fsdb");
		$fsdbDumpvars(0, tb_i2c_uvm, "+all");
	end
		

endmodule
