class i2c_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(i2c_scoreboard)

	uvm_tlm_analysis_fifo #(i2c_exp_item) exp_fifo;
	uvm_tlm_analysis_fifo #(i2c_act_item) act_fifo;

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

	int seq_num = 0;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		exp_fifo = new("exp_fifo", this);
		act_fifo = new("act_fifo", this);
	endfunction

	task run_phase(uvm_phase phase);
		i2c_exp_item exp_item;
		i2c_act_item act_item;
	
		forever begin
			exp_fifo.get(exp_item);
			act_fifo.get(act_item);
	
			if({exp_item.addr, exp_item.rw} !== {act_item.addr, act_item.rw}) begin
				`uvm_error(get_type_name(), $sformatf("ADDR/RW MISMATCH, sequence=%0d, exp=0x%02h, act=0x%02h", 
														seq_num, {exp_item.addr, exp_item.rw}, {act_item.addr, act_item.rw}))
				addr_rw_fail_cnt++;
			end
			else begin
				`uvm_info(get_type_name(), $sformatf("ADDR/RW MATCH, sequence=%0d, exp=0x%02h, act=0x%02h", 
														seq_num, {exp_item.addr, exp_item.rw}, {act_item.addr, act_item.rw}), UVM_MEDIUM)
				addr_rw_pass_cnt++;
			end
	
			if(exp_item.addr == 7'h12) begin
				if(act_item.addr_ack) begin
					`uvm_error(get_type_name(), $sformatf("ADDR ACK ERROR, sequence=%0d, ack=%0d", 
														seq_num, act_item.addr_ack))
					addr_ack_fail_cnt++;
				end
				else begin
					`uvm_info(get_type_name(), $sformatf("ADDR ACK PASS, sequence=%0d, ack=%0d", 
														seq_num, act_item.addr_ack), UVM_MEDIUM)
					addr_ack_pass_cnt++;
				end
			end
			else begin
				if(act_item.addr_ack) begin
					`uvm_info(get_type_name(), $sformatf("ADDR NACK PASS, sequence=%0d, ack=%0d", 
														seq_num, act_item.addr_ack), UVM_MEDIUM)
					addr_nack_pass_cnt++;
				end
				else begin
					`uvm_error(get_type_name(), $sformatf("ADDR NACK ERROR, sequence=%0d, ack=%0d", 
														seq_num, act_item.addr_ack))
					addr_nack_fail_cnt++;
				end
	
				seq_num++;
				continue;
			end
	
			if(!exp_item.rw) begin
				compare_write_data(exp_item, act_item);
				compare_slave_data(exp_item, act_item);
				compare_write_ack(exp_item, act_item);
	
				if(exp_item.data.size() > 0) begin
					last_write_data = exp_item.data[exp_item.data.size()-1];
				end
	
				write_total++;
			end
			else begin
				compare_read_data(exp_item, act_item);
				compare_read_ack(act_item);
	
				read_total++;
			end
	
			seq_num++;
		end
	endtask

	task compare_write_data(i2c_exp_item exp_item, i2c_act_item act_item);
		if(exp_item.data.size() != act_item.data.size()) begin
			`uvm_error(get_type_name(), $sformatf("WRITE DATA SIZE MISMATCH, exp=%0d, act=%0d", 
														exp_item.data.size(), act_item.data.size()))
			write_data_fail_cnt++;
		end
	
		foreach(exp_item.data[i]) begin
			if(i >= act_item.data.size()) begin
				`uvm_error(get_type_name(), $sformatf("WRITE DATA MISSING, i=%0d, exp=0x%02h", 
														i, exp_item.data[i]))
				write_data_fail_cnt++;
			end
			else if(exp_item.data[i] !== act_item.data[i]) begin
				`uvm_error(get_type_name(), $sformatf("WRITE DATA MISMATCH, i=%0d, exp=0x%02h, act=0x%02h", 
														i, exp_item.data[i], act_item.data[i]))
				write_data_fail_cnt++;
			end
			else begin
				`uvm_info(get_type_name(), $sformatf("WRITE DATA MATCH, i=%0d, exp=0x%02h, act=0x%02h", 
														i, exp_item.data[i], act_item.data[i]), UVM_MEDIUM)
				write_data_pass_cnt++;
			end
		end
	endtask

	task compare_slave_data(i2c_exp_item exp_item, i2c_act_item act_item);
		if((exp_item.data.size() != act_item.data.size()) ||
		   (exp_item.data.size() != act_item.slave_data.size())) begin
			`uvm_error(get_type_name(), $sformatf("DATA SIZE MISMATCH, exp=%0d, act=%0d, slave=%0d", 
														exp_item.data.size(), act_item.data.size(), act_item.slave_data.size()))
			write_slv_fail_cnt++;
		end
	
		foreach(exp_item.data[i]) begin
			if((i >= act_item.data.size()) || (i >= act_item.slave_data.size())) begin
				`uvm_error(get_type_name(), $sformatf("DATA MISSING, i=%0d, act_size=%0d, slave_size=%0d", 
														i, act_item.data.size(), act_item.slave_data.size()))
				write_slv_fail_cnt++;
			end
			else if((exp_item.data[i] !== act_item.slave_data[i]) ||
					(act_item.data[i] !== act_item.slave_data[i])) begin
				`uvm_error(get_type_name(), $sformatf("EXP/ACT/SLAVE MISMATCH, i=%0d, exp=0x%02h, act=0x%02h, slave=0x%02h", 
														i, exp_item.data[i], act_item.data[i], act_item.slave_data[i]))
				write_slv_fail_cnt++;
			end
			else begin
				`uvm_info(get_type_name(), $sformatf("EXP/ACT/SLAVE MATCH, i=%0d, exp=0x%02h, act=0x%02h, slave=0x%02h", 
														i, exp_item.data[i], act_item.data[i], act_item.slave_data[i]), UVM_MEDIUM)
				write_slv_pass_cnt++;
			end
		end
	endtask

	task compare_write_ack(i2c_exp_item exp_item, i2c_act_item act_item);
		if(exp_item.data.size() != act_item.data_ack.size()) begin
			`uvm_error(get_type_name(), $sformatf("WRITE ACK SIZE MISMATCH, exp=%0d, act=%0d", 
														exp_item.data.size(), act_item.data_ack.size()))
			data_ack_fail_cnt++;
		end
	
		foreach(exp_item.data[i]) begin
			if(i >= act_item.data_ack.size()) begin
				`uvm_error(get_type_name(), $sformatf("WRITE ACK MISSING, i=%0d", i))
				data_ack_fail_cnt++;
			end
			else if(act_item.data_ack[i]) begin
				`uvm_error(get_type_name(), $sformatf("WRITE ACK ERROR, i=%0d, ack=%0d", 
														i, act_item.data_ack[i]))
				data_ack_fail_cnt++;
			end
			else begin
				`uvm_info(get_type_name(), $sformatf("WRITE ACK PASS, i=%0d, ack=%0d", 
														i, act_item.data_ack[i]), UVM_MEDIUM)
				data_ack_pass_cnt++;
			end
		end
	endtask

	task compare_read_data(i2c_exp_item exp_item, i2c_act_item act_item);
		if((exp_item.data.size() != 1) || (act_item.data.size() != 1)) begin
			`uvm_error(get_type_name(), $sformatf("READ DATA SIZE MISMATCH, master_rx=%0d, bus=%0d", exp_item.data.size(), act_item.data.size()))
			read_data_fail_cnt++;
		end
		else if((last_write_data !== exp_item.data[0]) ||
				(last_write_data !== act_item.data[0]) ||
				(exp_item.data[0] !== act_item.data[0])) begin
			`uvm_error(get_type_name(), $sformatf("READ DATA MISMATCH, expected=0x%02h, master_rx=0x%02h, bus=0x%02h", last_write_data, exp_item.data[0], act_item.data[0]))
			read_data_fail_cnt++;
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("READ DATA MATCH, expected=0x%02h, master_rx=0x%02h, bus=0x%02h", last_write_data, exp_item.data[0], act_item.data[0]), UVM_MEDIUM)
			read_data_pass_cnt++;
		end
	endtask

	task compare_read_ack(i2c_act_item act_item);
		if(act_item.data_ack.size() == 0) begin
			`uvm_error(get_type_name(), "READ ACK MISSING")
			data_ack_fail_cnt++;
		end
		else if(!act_item.data_ack[0]) begin
			`uvm_error(get_type_name(), $sformatf("READ ACK ERROR, ack=%0d", 
														act_item.data_ack[0]))
			data_ack_fail_cnt++;
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("READ ACK PASS, ack=%0d", 
														act_item.data_ack[0]), UVM_MEDIUM)
			data_ack_pass_cnt++;
		end
	endtask


	

	function void report_phase(uvm_phase phase);
		bit overall_pass;
	
		super.report_phase(phase);
	
		overall_pass = (addr_rw_fail_cnt    == 0) &&
					   (addr_ack_fail_cnt   == 0) &&
					   (addr_nack_fail_cnt  == 0) &&
					   (write_data_fail_cnt == 0) &&
					   (write_slv_fail_cnt  == 0) &&
					   (read_data_fail_cnt  == 0) &&
					   (data_ack_fail_cnt   == 0);
	
		`uvm_info(get_type_name(), "\n", UVM_LOW)
		`uvm_info(get_type_name(), "============ Scoreboard Summary ============", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Test Total         : %4d", seq_num), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Write              : %4d", write_total), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Read               : %4d", read_total), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Invalid Address    : %4d", addr_nack_pass_cnt + addr_nack_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), "--------------------------------------------", UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Address/RW         : PASS=%4d  FAIL=%4d", addr_rw_pass_cnt, addr_rw_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Address ACK        : PASS=%4d  FAIL=%4d", addr_ack_pass_cnt, addr_ack_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Address NACK       : PASS=%4d  FAIL=%4d", addr_nack_pass_cnt, addr_nack_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Write Data         : PASS=%4d  FAIL=%4d", write_data_pass_cnt, write_data_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Slave Data         : PASS=%4d  FAIL=%4d", write_slv_pass_cnt, write_slv_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Read Data          : PASS=%4d  FAIL=%4d", read_data_pass_cnt, read_data_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("Data ACK/NACK      : PASS=%4d  FAIL=%4d", data_ack_pass_cnt, data_ack_fail_cnt), UVM_LOW)
		`uvm_info(get_type_name(), "--------------------------------------------", UVM_LOW)
	
		if(overall_pass) begin
			`uvm_info(get_type_name(), "Overall Result      : PASS", UVM_LOW)
		end
		else begin
			`uvm_info(get_type_name(), "Overall Result      : FAIL", UVM_LOW)
		end
	
		`uvm_info(get_type_name(), "============================================", UVM_LOW)
	endfunction

endclass

