import uvm_pkg::*;
`include "uvm_macros.svh"

`include "spi_if.sv"
`include "spi_seq_item.sv"
`include "spi_sequence.sv"
`include "spi_driver.sv"
`include "spi_cmd_monitor.sv"
`include "spi_cmd_agent.sv"
`include "spi_bus_monitor.sv"
`include "spi_bus_agent.sv"
`include "spi_slave_model.sv"
`include "spi_scoreboard.sv"
`include "spi_coverage.sv"
`include "spi_env.sv"
`include "spi_test.sv"


module tb_spi_uvm();


	logic clk;
	logic rst;

	always #5 clk = ~clk;

	initial begin
		clk = 0;
		rst = 1;

		repeat(3) @(posedge clk);

		rst = 0;

		@(posedge clk);
	end

	spi_if vif(clk, rst);


	spi_master dut(
		.clk		(clk			),
		.rst		(rst			),

		.cpol		(vif.cpol		),
		.cpha		(vif.cpha		),
		.clk_div	(vif.clk_div	),

		.tx_data	(vif.tx_data	),
		.start		(vif.start		),

		.rx_data	(vif.rx_data	),
		.done		(vif.done		),
		.busy		(vif.busy		),

		.sclk		(vif.sclk		),
		.mosi		(vif.mosi		),
		.miso		(vif.miso		),
		.cs_n		(vif.cs_n		)
	);


	initial begin
		uvm_config_db#(virtual spi_if)::set(null, "*", "vif", vif);

		run_test();
	end

	initial begin
		$fsdbDumpfile("novas.fsdb");
		$fsdbDumpvars(0, tb_spi_uvm, "+all");
	end


endmodule
