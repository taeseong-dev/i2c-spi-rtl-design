import uvm_pkg::*;
`include "uvm_macros.svh"

interface i2c_if(input logic clk, input logic rst);


	logic 			cmd_start;
	logic 			cmd_write;
	logic 			cmd_read;
	logic 			cmd_stop;

	logic	[07:00] tx_data;
	logic 	[07:00] rx_data;
	logic 			ack_in;
	logic 			ack_out;
	logic 			done;
	logic 			busy;

	logic 	[07:00] slave_data;
	logic 			slave_done;

	logic 			scl;
	wand 			sda;


	clocking drv_cb @(posedge clk);
		default input #1step output #0;
		input done;
		input busy;
		input rx_data;
		input ack_out;

		output cmd_start;
		output cmd_write;
		output cmd_read;
		output cmd_stop;
		output tx_data;
		output ack_in;

	endclocking

	clocking mon_cb @(posedge clk);
		default input #1step;
		input done;
		input rx_data;
		input tx_data;
		input slave_data;
		input slave_done;
		input ack_out;
		input scl;
		input sda;
	endclocking

endinterface

class i2c_seq_item extends uvm_sequence_item;

	rand logic [07:00] tx_data[];
		 logic [07:00] rx_data;
	rand bit		   is_read;
	rand logic [06:00] addr;

	rand int		   num_data;

		 logic [07:00] slave_data[$];

		 logic [07:00] actual_data[$];
		 logic [06:00] actual_addr;
		 logic 		   actual_rw;

		 logic         actual_addr_ack;
		 logic		   actual_data_ack;


	`uvm_object_utils_begin(i2c_seq_item)
		`uvm_field_array_int	(tx_data		, UVM_ALL_ON)
		`uvm_field_int			(rx_data		, UVM_ALL_ON)
		`uvm_field_queue_int	(slave_data		, UVM_ALL_ON)
		`uvm_field_int			(is_read		, UVM_ALL_ON)
		`uvm_field_int			(addr 			, UVM_ALL_ON)
		`uvm_field_queue_int	(actual_data 	, UVM_ALL_ON)
		`uvm_field_int			(actual_addr 	, UVM_ALL_ON)
		`uvm_field_int			(actual_rw		, UVM_ALL_ON)
		`uvm_field_int			(actual_addr_ack, UVM_ALL_ON)
		`uvm_field_int			(actual_data_ack, UVM_ALL_ON)
		`uvm_field_int			(num_data 		, UVM_ALL_ON)
	`uvm_object_utils_end
	
	constraint c_addr {addr dist{ 7'h12 := 96, [7'h00 : 7'h11] :/ 5, [7'h13:7'h7f] :/ 5};}
	//constraint c_addr {addr == 7'h12;}
	constraint c_num_data {num_data inside {[1:8]}; tx_data.size() == num_data;}

	function new(string name="i2c_seq_item");
		super.new(name);
	endfunction

//	function string convert2string();
//		return $sformatf("tx_data=0x%02h, rx_data=0x%02h, read = %0d", tx_data, rx_data, is_read);
//	endfunction
	function string convert2string();
	
		string str;
		str = $sformatf("addr=0x%02h, is_read=0x%02h, num_data=0x%0d\n", addr, is_read, num_data);
		foreach(tx_data[i]) begin
			str = {str, $sformatf("tx_data[%0d]=0x%02h\n", i, tx_data[i])};
		end
		return str;

	endfunction

endclass

/////////

class i2c_base_seq extends uvm_sequence#(i2c_seq_item);
	`uvm_object_utils(i2c_base_seq)

	function new(string name = "i2c_base_seq");
		super.new(name);
	endfunction

	task do_write();
		i2c_seq_item item;
		item = i2c_seq_item::type_id::create("item");
		
		start_item(item);
		if(!item.randomize() with { is_read == 0;})
			`uvm_fatal(get_type_name(), "do_write() Randomize() fail!")
			`uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)
		finish_item(item);
		//`uvm_info(get_type_name(), $sformatf("do_write() complete : addr : 0x%02h, tx_data_size=0x%02h, tx_data=0x%02h", item.addr, item.tx_data.size(), item.tx_data[0]), UVM_LOW)
	endtask

	task do_read();
		i2c_seq_item item;
		item = i2c_seq_item::type_id::create("item");

		start_item(item);
		//if(!item.randomize() with { is_read == 1; tx_data == 8'h00;})
		if(!item.randomize() with { is_read == 1; num_data == 1;})
			`uvm_fatal(get_type_name(), "do_read() Randomize() fail!")
		//item.rx_data = 8'h77;
		finish_item(item);
		//`uvm_info(get_type_name(), $sformatf("do_read() complete : addr : 0x%02h, rx_data=0x%02h", item.addr, item.rx_data), UVM_LOW)
	endtask



endclass

////
class i2c_write_seq extends i2c_base_seq;
	`uvm_object_utils(i2c_write_seq)
	int num_loop = 0;

	function new(string name = "i2c_write_seq");
		super.new(name);
	endfunction

	virtual task body();
		for (int i=0; i<num_loop; i++) begin
			do_write();
		end
	endtask

endclass

class i2c_read_seq extends i2c_base_seq;
	`uvm_object_utils(i2c_read_seq)
	int num_loop = 0;

	function new(string name = "i2c_read_seq");
		super.new(name);
	endfunction

	virtual task body();
		for (int i=0; i<num_loop; i++) begin
			do_read();
		end
	endtask

endclass

class i2c_write_read_seq extends i2c_base_seq;
	`uvm_object_utils(i2c_write_read_seq)
	int num_loop = 0;

	function new(string name = "i2c_write_read_seq");
		super.new(name);
	endfunction

	virtual task body();
		for (int i=0; i<num_loop; i++) begin
			do_write();
			do_read();
		end
	endtask

endclass


class i2c_rand_seq extends i2c_base_seq;
	`uvm_object_utils(i2c_rand_seq)
	int num_loop = 0;

	function new(string name = "i2c_rand_seq");
		super.new(name);
	endfunction

	virtual task body();

		repeat(num_loop) begin
			if($urandom_range(0,1))
				do_write();
			else
				do_read();
		end

	endtask

endclass


class i2c_coverage extends uvm_subscriber #(i2c_seq_item);
	`uvm_component_utils(i2c_coverage)

	logic [07:00] cov_tx_data;
	logic [07:00] cov_num_data;
	logic		  cov_is_read;
	logic [06:00] cov_addr;

	covergroup cg_data;
		cp_tx_data : coverpoint cov_tx_data {
			bins zero 		= {8'h00};
			bins max  		= {8'hff};

			bins alt_01 	= {8'h55};
			bins alt_10 	= {8'haa};
			
			bins lsb_only 	= {8'h01};
			bins msb_only 	= {8'h80};

			bins low 		= {[8'h02 : 8'h3f]};
			bins mid 		= {[8'h40 : 8'h7f],
							   [8'h81 : 8'ha9],
							   [8'hab : 8'hbf]};
			bins high 		= {[8'hc0 : 8'hfe]};
		}
	endgroup

	covergroup cg_num_data;
		cp_num_data : coverpoint cov_num_data{
			bins len[] = {[1:8]};
		}
	endgroup

	covergroup cg_rw;
		cp_rw : coverpoint cov_is_read {
			bins write = {0};
			bins read  = {1};
		}
	endgroup

	covergroup cg_addr;
		cp_addr : coverpoint cov_addr {
			bins valid_addr = {7'h12};
			bins invalid_addr = default;
		}
	endgroup

	function new(string name, uvm_component parent);
		super.new(name, parent);
		cg_data 	= new();
		cg_num_data = new();
		cg_rw 		= new();
		cg_addr		= new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cov_tx_data 	= 0;
		cov_num_data 	= 0;
		cov_is_read 	= 0;
		cov_addr		= 0;
	endfunction

	function void write(i2c_seq_item item);
		cov_is_read = item.actual_rw;
		cg_rw.sample();
		cov_num_data = item.actual_data.size();
		cg_num_data.sample();
		cov_addr = item.actual_addr;
		cg_addr.sample();
		foreach(item.actual_data[i]) begin
			cov_tx_data = item.actual_data[i];
			cg_data.sample();
		end
	endfunction

	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(), "==== Coverage Summary ====", UVM_LOW);
		`uvm_info(get_type_name(), $sformatf("Address  : %.1f%%", cg_addr.cp_addr.get_coverage()), UVM_LOW);
		`uvm_info(get_type_name(), $sformatf("RW       : %.1f%%", cg_rw.cp_rw.get_coverage()), UVM_LOW);
		`uvm_info(get_type_name(), $sformatf("DATA     : %.1f%%", cg_data.cp_tx_data.get_coverage()), UVM_LOW);
		`uvm_info(get_type_name(), $sformatf("Num_Data : %.1f%%", cg_num_data.cp_num_data.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), "==== Coverage Summary ====", UVM_LOW);
	endfunction


endclass

class i2c_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(i2c_scoreboard)
	//uvm_analysis_imp #(i2c_seq_item, i2c_scoreboard) ap_imp;

	uvm_tlm_analysis_fifo #(i2c_seq_item) exp_fifo;
	uvm_tlm_analysis_fifo #(i2c_seq_item) act_fifo;

	logic [07:00] last_write_data = 8'h77;

	int write_total = 0;
	int read_total = 0;


	int write_data_pass_cnt = 0;
	int write_data_fail_cnt = 0;

	int write_slv_pass_cnt = 0;
	int write_slv_fail_cnt = 0;


	int read_data_pass_cnt = 0;
	int read_data_fail_cnt = 0;

	int addr_rw_pass_cnt = 0;
	int addr_rw_fail_cnt = 0;

	int addr_ack_pass_cnt = 0;
	int addr_ack_fail_cnt = 0;

	int addr_nack_pass_cnt = 0;
	int addr_nack_fail_cnt = 0;

	int data_ack_pass_cnt = 0;
	int data_ack_fail_cnt = 0;

	int pass_cnt = 0;
	int fail_cnt = 0;

	bit [07:00] prev_tx_data;
	bit first = 1;

	int seq_num = 0;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//ap_imp = new("ap_imp",this);

		exp_fifo = new("exp_fifo", this);
		act_fifo = new("act_fifo", this);
	endfunction

	task run_phase(uvm_phase phase);

		i2c_seq_item exp_item;
		i2c_seq_item act_item;

		forever begin
			exp_fifo.get(exp_item);
			//`uvm_info(get_type_name(), $sformatf("EXP received num_data=%0d", exp_item.num_data), UVM_LOW)
			act_fifo.get(act_item);
			//`uvm_info(get_type_name(), $sformatf("ACT received num_data=%0d", act_item.num_data), UVM_LOW)
			

			//addr + rw 
			if({exp_item.addr, exp_item.is_read} !== {act_item.actual_addr ,act_item.actual_rw}) begin
				`uvm_error(get_type_name(), $sformatf("ADDR, RW MISMATCH, sequence=%0d, exp=0x%02h, act=0x%02h", 
														seq_num, {exp_item.addr, exp_item.is_read}, {act_item.actual_addr, act_item.actual_rw}))
				addr_rw_fail_cnt++;
			end
			else begin
				`uvm_info(get_type_name(), $sformatf("ADDR, RW MATCH, sequence=%0d, exp=0x%02h, act=0x%02h", 
														seq_num, {exp_item.addr, exp_item.is_read}, {act_item.actual_addr, act_item.actual_rw}), UVM_MEDIUM);
				addr_rw_pass_cnt++;
			end

			//addr + rw ack

			if(exp_item.addr == 7'h12) begin

				if(act_item.actual_addr_ack) begin
					`uvm_error(get_type_name(), $sformatf("ADDR_ACK ERROR, sequence=%0d, ack=%0d", seq_num, act_item.actual_addr_ack))
					addr_ack_fail_cnt++;
				end
				else begin
					`uvm_info(get_type_name(), $sformatf("ADDR_ACK_PASS, sequence=%0d, ack=%0d", seq_num, act_item.actual_addr_ack), UVM_MEDIUM);
					addr_ack_pass_cnt++;
				end

			end
			else begin
				if(act_item.actual_addr_ack) begin
					`uvm_info(get_type_name(), $sformatf("ADDR_NACK PASS, sequence=%0d, ack=%0d", seq_num, act_item.actual_addr_ack), UVM_MEDIUM);
					addr_nack_pass_cnt++;
				end
				else begin
					`uvm_error(get_type_name(), $sformatf("ADDR_MACK ERROR, sequence=%0d, ack=%0d", seq_num, act_item.actual_addr_ack))
					addr_nack_pass_cnt++;
				end
				seq_num++;
				continue;
			end
		


			//tx_data check
			if(!exp_item.is_read) begin

				foreach(exp_item.tx_data[i]) begin
					if(exp_item.tx_data[i] !== act_item.actual_data[i]) begin
						`uvm_error(get_type_name(), $sformatf("TX_DATA MISMATCH, i=%0d, exp=0x%02h, act=0x%02h", i, exp_item.tx_data[i], act_item.actual_data[i]))
						write_data_fail_cnt++;
					end
					else begin
						`uvm_info(get_type_name(), $sformatf("TX_DATA MATCH, i=%0d, exp=0x%02h, act=0x%02h", i, exp_item.tx_data[i], act_item.actual_data[i]), UVM_MEDIUM);
						write_data_pass_cnt++;
					end



					//exp_data <-> slave_data
					if(exp_item.tx_data.size() !== act_item.slave_data.size())
						`uvm_error(get_type_name(), $sformatf("SIZE MISMATCH, exp=%0d, slave=%0d", exp_item.tx_data.size(), act_item.slave_data.size()));
					if(exp_item.tx_data[i] !== act_item.slave_data[i]) begin
						`uvm_error(get_type_name(), $sformatf("EXP_TX_DATA <-> SLAVE_DATA MISMATCH, i=%0d, exp=0x%02h, act=0x%02h", i, exp_item.tx_data[i], act_item.slave_data[i]))
						write_slv_fail_cnt++;
					end
					else begin
						`uvm_info(get_type_name(), $sformatf("EXP_TX_DATA <-> SLAVE_DATA MATCH, i=%0d, exp=0x%02h, act=0x%02h", i, exp_item.tx_data[i], act_item.slave_data[i]), UVM_MEDIUM);
						write_slv_pass_cnt++;
					end
					

					if(act_item.actual_data_ack) begin
						`uvm_error(get_type_name(), $sformatf("WRITE_DATA_ACK ERROR, sequence=%0d, ack=%0d", seq_num, act_item.actual_data_ack))
						data_ack_fail_cnt++;
					end
					else begin
						`uvm_info(get_type_name(), $sformatf("WRITE_DATA_ACK PASS, sequence=%0d, ack=%0d", seq_num, act_item.actual_data_ack), UVM_MEDIUM)
						data_ack_pass_cnt++;
					end
				end
				last_write_data = exp_item.tx_data[exp_item.tx_data.size()-1];
				write_total++;
			end
			else begin
				if(last_write_data !== act_item.actual_data[0]) begin
					`uvm_error(get_type_name(), $sformatf("RX_DATA MISMATCH, exp=0x%02h, act=0x%02h", last_write_data, act_item.actual_data[0]))
					read_data_fail_cnt++;
				end
				else begin
					`uvm_info(get_type_name(), $sformatf("RX_DATA MATCH, exp=0x%02h, act=0x%02h", last_write_data, act_item.actual_data[0]), UVM_MEDIUM);
					read_data_pass_cnt++;
				end

				if(!act_item.actual_data_ack) begin
					`uvm_error(get_type_name(), $sformatf("READ_DATA_ACK ERROR, sequence=%0d, ack=%0d", seq_num, act_item.actual_data_ack))
					data_ack_fail_cnt++;
				end
				else begin
					`uvm_info(get_type_name(), $sformatf("READ_DATA_ACK PASS, sequence=%0d, ack=%0d", seq_num, act_item.actual_data_ack), UVM_MEDIUM)
					data_ack_pass_cnt++;
				end
				read_total++;
			end
			seq_num++;

		end

	endtask


	virtual function void report_phase (uvm_phase phase);

		bit overall_pass;

		super.report_phase(phase);

   		overall_pass =  (addr_rw_fail_cnt    == 0) &&
						(addr_ack_fail_cnt   == 0) &&
        				(addr_nack_fail_cnt  == 0) &&
        				(write_data_fail_cnt == 0) &&
        				(read_data_fail_cnt  == 0);


		`uvm_info(get_type_name(), "\n\n", UVM_LOW)
		`uvm_info(get_type_name(), "============ Scoreboard Summary =============", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("   Test Total        : %4d", seq_num), UVM_LOW)
		`uvm_info(get_type_name(), "", UVM_LOW)
   		`uvm_info(get_type_name(), "Transaction Summary", UVM_LOW)
   		`uvm_info(get_type_name(), "********************************************", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("   WRITE             : %4d",write_total), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("   READ              : %4d",read_total), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("   Address NACK      : %4d",(addr_nack_pass_cnt + addr_nack_fail_cnt)), UVM_LOW)
    	`uvm_info(get_type_name(), "", UVM_LOW)
    	`uvm_info(get_type_name(), "Verification Result", UVM_LOW)
   		`uvm_info(get_type_name(), "********************************************", UVM_LOW)


		`uvm_info(get_type_name(), $sformatf("   Address/RW        : PASS=%5d  FAIL=%4d",addr_rw_pass_cnt, addr_rw_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("   Address ACK       : PASS=%5d  FAIL=%4d",addr_ack_pass_cnt, addr_ack_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("   Address NACK      : PASS=%5d  FAIL=%4d",addr_nack_pass_cnt, addr_nack_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("   Write Data (Byte) : PASS=%5d  FAIL=%4d",write_data_pass_cnt, write_data_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("   Read  Data        : PASS=%5d  FAIL=%4d",read_data_pass_cnt, read_data_fail_cnt), UVM_LOW)
   		`uvm_info(get_type_name(), "********************************************", UVM_LOW)
    	if (overall_pass) begin
			`uvm_info(get_type_name(), 		 "Overall Result       : PASS", UVM_LOW)
		end
		else begin
			`uvm_info(get_type_name(), 		 "Overall Result       : FAIL", UVM_LOW)
		end
		`uvm_info(get_type_name(), "============================================", UVM_LOW)

//		`uvm_info(get_type_name(), "\n\n", UVM_LOW)
	endfunction

endclass

class i2c_monitor extends uvm_monitor;
	`uvm_component_utils(i2c_monitor)

	uvm_analysis_port #(i2c_seq_item) ap;
	virtual i2c_if vif;

	logic sda_prev = 0;
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

		
		wait(vif.rst == 0);
		repeat(3) @(vif.drv_cb);

		forever begin
			i2c_seq_item item = i2c_seq_item::type_id::create("item");
					
			wait_start();
			num = 0;
			get_addr(item);
			//get_data(item);
			get_data_temp(item);

			//get slave_rx_data
			//if(!item.actual_rw) begin
			//	wait(vif.mon_cb.slave_done);
			//	item.slave_data = vif.mon_cb.slave_data;
			//	`uvm_info(get_type_name(), $sformatf("slave_data=0x%02h", item.slave_data), UVM_MEDIUM)

			//end

			//wait_stop();
			foreach(item.actual_data[i]) begin
				`uvm_info(get_type_name(), $sformatf("actual_data[%0d]=0x%02h", i, item.actual_data[i]), UVM_MEDIUM)
			end
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


	task get_addr(i2c_seq_item item);

		bit [07:00] addr_data;

		for (int i=7; i>=0; i--) begin
			@(posedge vif.mon_cb.scl);
			addr_data[i] = vif.mon_cb.sda;
		end

		item.actual_addr = addr_data[07:01];
		item.actual_rw   = addr_data[0];

		@(posedge vif.mon_cb.scl);
		item.actual_addr_ack = vif.mon_cb.sda;
		//item.addr = vif.mon_cb.tx_data[7:1];
		//item.is_read = vif.mon_cb.tx_data[0];


		//`uvm_info(get_type_name(), $sformatf("monitoring.. actual_addr = 0x%02h, actual_rw = %d", item.actual_addr, item.actual_rw), UVM_LOW)

	endtask

	task get_data(i2c_seq_item item);
		logic [07:00] actual_data;

			for(int i=7; i>=0; i--) begin
				@(posedge vif.mon_cb.scl);
				actual_data[i] = vif.mon_cb.sda;
//			`uvm_info(get_type_name(), $sformatf(" actual_data[i] = %0d  ", actual_data[i]), UVM_LOW)
			end
			
			//item.actual_data = actual_data;
			item.actual_data.push_back(actual_data);

			@(posedge vif.mon_cb.scl);
			item.actual_data_ack = (vif.mon_cb.sda);

			//item.tx_data = vif.mon_cb.tx_data;
			

			`uvm_info(get_type_name(), $sformatf("monitoring.. actual_data = 0x%02h, actual_data_ack = %d, data_size = %d", 
												item.actual_data[num], item.actual_data_ack, item.actual_data.size()), UVM_MEDIUM)
			num++;

//		end
	endtask
	

	task get_data_temp(i2c_seq_item item);
		fork
			begin
				forever begin
					get_data(item);
				end
			end

			begin
				forever begin
					@(posedge vif.mon_cb.slave_done);
						if(!item.actual_rw) begin
							item.slave_data.push_back(vif.mon_cb.slave_data);
							`uvm_info(get_type_name(), $sformatf("slave_data=0x%02h, size=%0d", vif.mon_cb.slave_data, item.slave_data.size()), UVM_MEDIUM) 
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

class i2c_driver extends uvm_driver #(i2c_seq_item);
	`uvm_component_utils(i2c_driver)
	uvm_analysis_port #(i2c_seq_item) ap;

	virtual i2c_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		ap = new("ap", this);
		if(!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal(get_type_name(), "i2c interface is not found in config_db");
		end
	endfunction


	task run_phase(uvm_phase phase);
		i2c_seq_item item;
		i2c_seq_item exp_item;

		
		//i2c_init
		i2c_init();
		wait(vif.rst == 0);
		repeat(3) @(vif.drv_cb);

		forever begin
			seq_item_port.get_next_item(item);

			$cast(exp_item, item.clone());

			`uvm_info(get_type_name(), $sformatf("send expected item, num_data=%0d",exp_item.num_data), UVM_MEDIUM)
			ap.write(exp_item);
				
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
		wait(vif.done == 1);
		@(vif.drv_cb);
		vif.drv_cb.cmd_start <= 0;
		`uvm_info(get_type_name(), ("start done"), UVM_HIGH)
	endtask

	task i2c_write(logic [07:00] data);
		vif.drv_cb.cmd_write <= 1;
		vif.drv_cb.tx_data   <= data;
		@(vif.drv_cb);
		wait(vif.done == 1);
		@(vif.drv_cb);
		vif.drv_cb.cmd_write <= 0;
	endtask

	task i2c_read();
		vif.drv_cb.cmd_read <= 1;
		vif.drv_cb.ack_in <= 1;
		@(vif.drv_cb);
		wait(vif.done == 1);
		@(vif.drv_cb);
		vif.drv_cb.cmd_read <= 0;
		vif.drv_cb.ack_in <= 0;
	endtask

	task i2c_stop();
		vif.drv_cb.cmd_stop <= 1;
		@(vif.drv_cb);
		wait(vif.done == 1);
		@(vif.drv_cb);
		vif.drv_cb.cmd_stop <= 0;
	endtask

endclass

class i2c_agent extends uvm_agent;
	`uvm_component_utils(i2c_agent)
	
	i2c_driver drv;
	i2c_monitor mon;
	uvm_sequencer#(i2c_seq_item) sqr;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv = i2c_driver::type_id::create("drv", this);
		mon = i2c_monitor::type_id::create("mon", this);
		sqr = uvm_sequencer#(i2c_seq_item)::type_id::create("sqr", this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction

endclass

class i2c_env extends uvm_env;
	`uvm_component_utils(i2c_env)
	
	i2c_agent agt;
	i2c_scoreboard scb;
	i2c_coverage cov;


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agt = i2c_agent::type_id::create("agt", this);
		scb = i2c_scoreboard::type_id::create("scb", this);
		cov = i2c_coverage::type_id::create("cov", this);		
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		//agt.mon.ap.connect(scb.ap_imp);
		agt.drv.ap.connect(scb.exp_fifo.analysis_export);
		agt.mon.ap.connect(scb.act_fifo.analysis_export);

		agt.mon.ap.connect(cov.analysis_export);
	endfunction


endclass


class i2c_base_test extends uvm_test;
	`uvm_component_utils(i2c_base_test)

	i2c_env env;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = i2c_env::type_id::create("env", this);
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase); //before run
		`uvm_info(get_type_name(), "===== UVM hierarchy ====", UVM_MEDIUM)
		uvm_top.print_topology();
	endfunction

	virtual task run_phase(uvm_phase phase);
		
	endtask

endclass

class i2c_write_test extends i2c_base_test;
	`uvm_component_utils(i2c_write_test)


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		i2c_write_seq seq;
		phase.raise_objection(this);
		seq = i2c_write_seq::type_id::create("seq");
		seq.num_loop = 10;
		seq.start(env.agt.sqr);
		phase.drop_objection(this);
	endtask

endclass

class i2c_read_test extends i2c_base_test;
	`uvm_component_utils(i2c_read_test)


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		i2c_read_seq seq;
		phase.raise_objection(this);
		seq = i2c_read_seq::type_id::create("seq");
		seq.num_loop = 2;
		seq.start(env.agt.sqr);
		phase.drop_objection(this);
	endtask

endclass

class i2c_write_read_test extends i2c_base_test;
	`uvm_component_utils(i2c_write_read_test)


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		i2c_write_read_seq seq;
		phase.raise_objection(this);
		seq = i2c_write_read_seq::type_id::create("seq");
		seq.num_loop = 100;
		seq.start(env.agt.sqr);
		phase.drop_objection(this);
	endtask

endclass

class i2c_rand_test extends i2c_base_test;
	`uvm_component_utils(i2c_rand_test)


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		i2c_rand_seq seq;
		phase.raise_objection(this);
		seq = i2c_rand_seq::type_id::create("seq");
		seq.num_loop = 1000;
		seq.start(env.agt.sqr);
		phase.drop_objection(this);
	endtask

endclass


module tb_i2c_uvm();

	logic clk;
	logic rst;

	always #5 clk =~ clk;

	initial begin
		clk = 0;
		rst = 1;
		repeat (3) @(posedge clk);
		rst = 0;
		@(posedge clk);
	end

	i2c_if vif(clk,rst);


	i2c_top dut(

	.clk				(clk			),
	.rst				(rst			),
	.cmd_start			(vif.cmd_start	),
	.cmd_write			(vif.cmd_write	),
	.cmd_read			(vif.cmd_read	),
	.cmd_stop			(vif.cmd_stop	),
	.tx_data			(vif.tx_data	),
	.ack_in				(vif.ack_in		),

	.rx_data			(vif.rx_data	),
	.done				(vif.done		),
	.ack_out			(vif.ack_out	),
	.busy				(vif.busy		),
                		                
	.slave_data			(vif.slave_data	),
	.slave_done			(vif.slave_done	),
                		                
	.scl				(vif.scl		),
	.sda				(vif.sda		)
);


	initial begin
		uvm_config_db#(virtual i2c_if)::set(null, "*", "vif", vif);
		run_test();
	end

	initial begin
		$fsdbDumpfile("novas.fsdb");
		$fsdbDumpvars(0, tb_i2c_uvm, "+all");
	end
		

endmodule
