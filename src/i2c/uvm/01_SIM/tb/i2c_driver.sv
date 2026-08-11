class i2c_driver extends uvm_driver #(i2c_seq_item);
	`uvm_component_utils(i2c_driver)

	virtual i2c_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(), "i2c interface is not found in config_db");
		end
	endfunction


	task run_phase(uvm_phase phase);
		i2c_seq_item item;

		
		//i2c_init
		i2c_init();
		wait(vif.rst == 0);
		repeat(3) @(vif.drv_cb);

		forever begin
			seq_item_port.get_next_item(item);

			//start
			i2c_start();

			//write_address+rw
			`uvm_info(get_type_name(), ("address start"), UVM_HIGH)
			i2c_write({item.addr, item.is_read});
			`uvm_info(get_type_name(), $sformatf("address done, addr : 0x%02h, is_read : %b", item.addr, item.is_read), UVM_MEDIUM)

			if(!item.is_read) begin
			//data
			`uvm_info(get_type_name(), ("data send start"), UVM_HIGH)
				foreach(item.tx_data[i]) begin
					i2c_write(item.tx_data[i]);
					`uvm_info(get_type_name(), $sformatf("data[%0d]=0x%02h", i, item.tx_data[i]), UVM_MEDIUM)
				end
			end
			else begin
				`uvm_info(get_type_name(), ("data read start"), UVM_HIGH)
				i2c_read();
			end


			//stop
			`uvm_info(get_type_name(), ("stop start"), UVM_HIGH)
			i2c_stop();
			`uvm_info(get_type_name(), ("stop done"), UVM_MEDIUM)

			seq_item_port.item_done();
		end

	endtask

	task i2c_init();
		vif.drv_cb.cmd_start <= 0;
		vif.drv_cb.cmd_write <= 0;
		vif.drv_cb.cmd_read  <= 0;
		vif.drv_cb.cmd_stop  <= 0;
		vif.drv_cb.tx_data   <= 0;
		vif.drv_cb.ack_in    <= 0;
	endtask

	task i2c_start();	

		while(vif.drv_cb.busy) @(vif.drv_cb);
		@(vif.drv_cb);
		vif.drv_cb.cmd_start <= 1;
		@(vif.drv_cb);
		vif.drv_cb.cmd_start <= 0;
		@(vif.drv_cb);
		wait(vif.drv_cb.done == 1);
		@(vif.drv_cb);
		`uvm_info(get_type_name(), ("start done"), UVM_HIGH)
	endtask

	task i2c_write(logic [07:00] data);
		@(vif.drv_cb);
		vif.drv_cb.cmd_write <= 1;
		vif.drv_cb.tx_data   <= data;
		@(vif.drv_cb);
		vif.drv_cb.cmd_write <= 0;
		@(vif.drv_cb);
		wait(vif.drv_cb.done == 1);
		@(vif.drv_cb);
	endtask

	task i2c_read();
		vif.drv_cb.cmd_read <= 1;
		vif.drv_cb.ack_in <= 1;
		@(vif.drv_cb);
		vif.drv_cb.cmd_read <= 0;
		@(vif.drv_cb);
		wait(vif.drv_cb.done == 1);
		@(vif.drv_cb);
		vif.drv_cb.ack_in <= 0;
		@(vif.drv_cb);
	endtask

	task i2c_stop();
		vif.drv_cb.cmd_stop <= 1;
		@(vif.drv_cb);
		vif.drv_cb.cmd_stop <= 0;
		@(vif.drv_cb);
		wait(vif.drv_cb.done == 1);
		@(vif.drv_cb);
	endtask

endclass

