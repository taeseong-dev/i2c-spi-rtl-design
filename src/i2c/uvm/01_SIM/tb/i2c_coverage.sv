class i2c_coverage extends uvm_subscriber #(i2c_act_item);
	`uvm_component_utils(i2c_coverage)

	logic [07:00] cov_data;
	logic [03:00] cov_num_data;
	logic [06:00] cov_addr;
	logic		  cov_rw;

	covergroup cg_data;
		cp_data : coverpoint cov_data {
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

	covergroup cg_num_data;
		cp_num_data : coverpoint cov_num_data {
			bins len[] = {[1:8]};
		}
	endgroup

	covergroup cg_addr_rw;
		cp_addr : coverpoint cov_addr {
			bins valid_addr   = {7'h12};
			bins invalid_addr = default;
		}

		cp_rw : coverpoint cov_rw {
			bins write = {0};
			bins read  = {1};
		}

		cross_addr_rw : cross cp_addr, cp_rw;
	endgroup

	function new(string name, uvm_component parent);
		super.new(name, parent);

		cg_data		= new();
		cg_num_data	= new();
		cg_addr_rw	= new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		cov_data		= 0;
		cov_num_data	= 0;
		cov_addr		= 0;
		cov_rw			= 0;
	endfunction

	function void write(i2c_act_item item);
		cov_addr = item.addr;
		cov_rw   = item.rw;

		cg_addr_rw.sample();

		if(!item.rw && (item.addr == 7'h12)) begin
			cov_num_data = item.data.size();
			cg_num_data.sample();

			foreach(item.data[i]) begin
				cov_data = item.data[i];
				cg_data.sample();
			end
		end
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);

		`uvm_info(get_type_name(), "======= Coverage Summary =======", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Address       : %.1f%%", cg_addr_rw.cp_addr.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("R/W           : %.1f%%", cg_addr_rw.cp_rw.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Address x R/W : %.1f%%", cg_addr_rw.cross_addr_rw.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Write Data    : %.1f%%", cg_data.cp_data.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Write Length  : %.1f%%", cg_num_data.cp_num_data.get_coverage()), UVM_LOW)
		`uvm_info(get_type_name(), "================================", UVM_LOW)
	endfunction

endclass

