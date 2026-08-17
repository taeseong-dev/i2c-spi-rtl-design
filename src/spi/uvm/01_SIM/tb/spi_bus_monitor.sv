class spi_bus_monitor extends uvm_monitor;
	`uvm_component_utils(spi_bus_monitor)


	uvm_analysis_port #(spi_act_item) ap;

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
		spi_act_item item;


		wait(vif.rst == 0);
		repeat(3) @(vif.mon_cb);

		forever begin
			wait_start();

			item = spi_act_item::type_id::create("item");

			get_transaction(item);

			`uvm_info(get_type_name(), {"Bus transaction\n", item.convert2string()}, UVM_MEDIUM)

			ap.write(item);
		end
	endtask

	task wait_start();
		@(negedge vif.cs_n);
	endtask

	task get_transaction(spi_act_item item);
		for(int i=7; i>=0; i--) begin
			@(posedge vif.sclk);
	
			item.bus_tx_data[i] = vif.mosi;
			item.bus_rx_data[i] = vif.miso;
		end
	
		@(posedge vif.cs_n);
	
		@(posedge vif.mon_cb.slv_done);
	
		item.master_rx_data = vif.mon_cb.rx_data;
		item.slv_rx_data    = vif.mon_cb.slv_rx_data;
	endtask

endclass
