class spi_cmd_monitor extends uvm_monitor;
	`uvm_component_utils(spi_cmd_monitor)


	uvm_analysis_port #(spi_exp_item) ap;

	virtual spi_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		ap = new("ap", this);

		if(!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(), "spi interface is not found in config_db")
		end
	endfunction

	task run_phase(uvm_phase phase);
		spi_exp_item item;


		wait(vif.rst == 0);
		repeat(3) @(vif.mon_cb);

		forever begin
			wait_start();

			item = spi_exp_item::type_id::create("item");

			get_transaction(item);

			`uvm_info(get_type_name(), {"Expected transaction\n", item.convert2string()}, UVM_MEDIUM)

			ap.write(item);
		end
	endtask

	task wait_start();
		forever begin
			@(vif.mon_cb);

			if(vif.mon_cb.start) begin
				break;
			end
		end
	endtask

	task get_transaction(spi_exp_item item);
		item.tx_data = vif.mon_cb.tx_data;
	endtask

endclass
