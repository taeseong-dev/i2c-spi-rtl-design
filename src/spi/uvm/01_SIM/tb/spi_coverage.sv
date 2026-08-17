class spi_coverage extends uvm_subscriber #(spi_act_item);
	`uvm_component_utils(spi_coverage)


	logic [07:00] cov_tx_data;
	logic [07:00] cov_rx_data;

	covergroup cg_tx_data;
		cp_tx_data : coverpoint cov_tx_data {
			bins zero		= {8'h00};
			bins max		= {8'hff};

			bins alt_01		= {8'h55};
			bins alt_10		= {8'haa};

			bins lsb_only	= {8'h01};
			bins msb_only	= {8'h80};

			bins low		= {[8'h02 : 8'h3f]};
			bins mid		= {[8'h40 : 8'h7f],
							   [8'h81 : 8'ha9],
							   [8'hab : 8'hbf]};
			bins high		= {[8'hc0 : 8'hfe]};
		}
	endgroup

	covergroup cg_rx_data;
		cp_rx_data : coverpoint cov_rx_data {
			bins zero		= {8'h00};
			bins max		= {8'hff};

			bins alt_01		= {8'h55};
			bins alt_10		= {8'haa};

			bins lsb_only	= {8'h01};
			bins msb_only	= {8'h80};

			bins low		= {[8'h02 : 8'h3f]};
			bins mid		= {[8'h40 : 8'h7f],
							   [8'h81 : 8'ha9],
							   [8'hab : 8'hbf]};
			bins high		= {[8'hc0 : 8'hfe]};
		}
	endgroup

	function new(string name, uvm_component parent);
		super.new(name, parent);

		cg_tx_data = new();
		cg_rx_data = new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		cov_tx_data = 0;
		cov_rx_data = 0;
	endfunction

	function void write(spi_act_item item);
		cov_tx_data = item.bus_tx_data;
		cov_rx_data = item.bus_rx_data;

		cg_tx_data.sample();
		cg_rx_data.sample();
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);

		`uvm_info(get_type_name(), "======= Coverage Summary =======", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("MOSI Data : %.1f%%", cg_tx_data.cp_tx_data.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("MISO Data : %.1f%%", cg_rx_data.cp_rx_data.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), "================================", UVM_LOW)
	endfunction

endclass
