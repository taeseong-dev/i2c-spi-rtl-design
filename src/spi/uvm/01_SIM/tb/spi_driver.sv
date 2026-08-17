class spi_driver extends uvm_driver #(spi_seq_item);
	`uvm_component_utils(spi_driver)


	virtual spi_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(), "spi interface is not found in config_db")
		end
	endfunction

	task run_phase(uvm_phase phase);
		spi_seq_item item;


		spi_init();

		wait(vif.rst == 0);
		repeat(3) @(vif.drv_cb);

		forever begin
			seq_item_port.get_next_item(item);

			`uvm_info(get_type_name(), $sformatf("transfer start: tx_data=0x%02h", item.tx_data), UVM_HIGH)

			spi_transfer(item.tx_data);

			`uvm_info(get_type_name(), $sformatf("transfer done: tx_data=0x%02h", item.tx_data), UVM_MEDIUM)

			seq_item_port.item_done();
		end
	endtask

	task spi_init();
		vif.drv_cb.start   <= 1'b0;
		vif.drv_cb.tx_data <= 8'h00;
	endtask

	task spi_transfer(logic [07:00] data);
		while(vif.drv_cb.busy) begin
			@(vif.drv_cb);
		end

		@(vif.drv_cb);
		vif.drv_cb.tx_data <= data;
		vif.drv_cb.start   <= 1'b1;

		@(vif.drv_cb);
		vif.drv_cb.start <= 1'b0;

		wait(vif.drv_cb.done == 1'b1);
		@(vif.drv_cb);
	endtask

endclass
