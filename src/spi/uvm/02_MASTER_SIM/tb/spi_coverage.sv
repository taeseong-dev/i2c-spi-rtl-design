class spi_coverage extends uvm_subscriber #(spi_act_item);
	`uvm_component_utils(spi_coverage)


	logic [01:00] cov_mode;
	logic [07:00] cov_tx_data;
	logic [07:00] cov_rx_data;

	covergroup cg_mode;
		cp_mode : coverpoint cov_mode {
			bins mode_0 = {2'd0};
			bins mode_1 = {2'd1};
			bins mode_2 = {2'd2};
			bins mode_3 = {2'd3};
		}
	endgroup

	covergroup cg_data;
		cp_tx_data : coverpoint cov_tx_data {
			bins zero		= {8'h00};
			bins max		= {8'hff};
			bins alt_01		= {8'h55};
			bins alt_10		= {8'haa};
			bins others		= default;
		}

		cp_rx_data : coverpoint cov_rx_data {
			bins zero		= {8'h00};
			bins max		= {8'hff};
			bins alt_01		= {8'h55};
			bins alt_10		= {8'haa};
			bins others		= default;
		}
	endgroup

	function new(string name, uvm_component parent);
		super.new(name, parent);

		cg_mode = new();
		cg_data = new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		cov_mode    = 0;
		cov_tx_data = 0;
		cov_rx_data = 0;
	endfunction

	function void write(spi_act_item item);
		cov_mode    = {item.cpol, item.cpha};
		cov_tx_data = item.bus_tx_data;
		cov_rx_data = item.bus_rx_data;

		cg_mode.sample();
		cg_data.sample();
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);

		`uvm_info(get_type_name(), "======= Coverage Summary =======", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Mode      : %.1f%%", cg_mode.cp_mode.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("MOSI Data : %.1f%%", cg_data.cp_tx_data.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("MISO Data : %.1f%%", cg_data.cp_rx_data.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), "================================", UVM_LOW)
	endfunction

endclass
