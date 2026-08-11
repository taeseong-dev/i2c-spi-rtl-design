class i2c_cmd_monitor extends uvm_monitor;
	`uvm_component_utils(i2c_cmd_monitor)

	uvm_analysis_port #(i2c_exp_item) ap;

	virtual i2c_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		ap = new("ap", this);

		if(!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(), "i2c interface is not found in config_db")
		end
	endfunction

	task run_phase(uvm_phase phase);
		i2c_exp_item item;

		wait(vif.rst == 0);
		repeat(3) @(vif.mon_cb);

		forever begin
			wait_start();

			item = i2c_exp_item::type_id::create("item");

			get_transaction(item);

			`uvm_info(get_type_name(), {"Expected transaction\n", item.convert2string()}, UVM_MEDIUM)

			ap.write(item);
		end
	endtask

	task wait_start();
		wait(vif.mon_cb.cmd_start == 1);
	endtask

	task get_transaction(i2c_exp_item item);
		bit write_prev;
		bit read_prev;
		bit stop_prev;
		bit done_prev;

		bit addr_done;
		bit read_pending;

		write_prev  = vif.mon_cb.cmd_write;
		read_prev   = vif.mon_cb.cmd_read;
		stop_prev   = vif.mon_cb.cmd_stop;
		done_prev   = vif.mon_cb.done;
		addr_done   = 0;
		read_pending = 0;

		forever begin
			@(vif.mon_cb);

			if(vif.mon_cb.cmd_write && !write_prev) begin
				if(!addr_done) begin
					item.addr = vif.mon_cb.tx_data[07:01];
					item.rw   = vif.mon_cb.tx_data[0];
					addr_done = 1;
				end
				else begin
					item.data.push_back(vif.mon_cb.tx_data);
				end
			end

			if(vif.mon_cb.cmd_read && !read_prev) begin
				read_pending = 1;
			end

			if(read_pending && vif.mon_cb.done && !done_prev) begin
				item.data.push_back(vif.mon_cb.rx_data);
				read_pending = 0;
			end

			if(vif.mon_cb.cmd_stop && !stop_prev) begin
				break;
			end

			write_prev = vif.mon_cb.cmd_write;
			read_prev  = vif.mon_cb.cmd_read;
			stop_prev  = vif.mon_cb.cmd_stop;
			done_prev  = vif.mon_cb.done;
		end
	endtask

endclass


