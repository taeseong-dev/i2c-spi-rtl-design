class i2c_bus_monitor extends uvm_monitor;
	`uvm_component_utils(i2c_bus_monitor)

	uvm_analysis_port #(i2c_act_item) ap;
	virtual i2c_if vif;

	int num = 0;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		ap = new("ap", this);
		if(!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(), "i2c_if is not found in config_db");
		end
	endfunction

	task run_phase(uvm_phase phase);
		i2c_act_item item;
		
		wait(vif.rst == 0);
		repeat(3) @(vif.mon_cb);

		forever begin
			item = i2c_act_item::type_id::create("item");
					
			wait_start();
			num = 0;
			get_addr(item);
			get_data_temp(item);
			
			`uvm_info(get_type_name(), {"Bus transaction\n", item.convert2string()}, UVM_MEDIUM)
			
			ap.write(item);
		end
	endtask
	
	task wait_start();
		forever begin
			@(negedge vif.mon_cb.sda);
			if(vif.mon_cb.scl == 1) begin
				break;
			end
		end
	endtask

	task wait_stop();
		forever begin
			@(posedge vif.mon_cb.sda);
			if(vif.mon_cb.scl == 1) begin
				break;
			end
		end
	endtask

	task get_addr(i2c_act_item item);

		logic [07:00] addr_data;

		for (int i=7; i>=0; i--) begin
			@(posedge vif.mon_cb.scl);
			addr_data[i] = vif.mon_cb.sda;
		end

		item.addr = addr_data[07:01];
		item.rw   = addr_data[0];

		@(posedge vif.mon_cb.scl);
		item.addr_ack = vif.mon_cb.sda;

	endtask

	task get_data(i2c_act_item item);

		logic [07:00] data;

		for(int i=7; i>=0; i--) begin
			@(posedge vif.mon_cb.scl);
			data[i] = vif.mon_cb.sda;
		end
			
		item.data.push_back(data);

		@(posedge vif.mon_cb.scl);
		item.data_ack.push_back(vif.mon_cb.sda);

		`uvm_info(get_type_name(), $sformatf("data[%0d]=0x%02h, data_ack[%0d]=%0d", num, item.data[num], num, item.data_ack[num]), UVM_MEDIUM)

		num++;

	endtask

	task get_data_temp(i2c_act_item item);
		fork
			begin
				forever begin
					get_data(item);
				end
			end

			begin
				forever begin
					@(posedge vif.mon_cb.slave_done);
					if(!item.rw) begin
						item.slave_data.push_back(vif.mon_cb.slave_data);
							
						`uvm_info(get_type_name(), $sformatf("slave_data[%0d]=0x%02h", item.slave_data.size()-1, vif.mon_cb.slave_data), UVM_MEDIUM)
					end
				end
			end

			begin
				wait_stop();
			end
		join_any

		disable fork;

	endtask

endclass

