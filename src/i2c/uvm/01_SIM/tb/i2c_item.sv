class i2c_seq_item extends uvm_sequence_item;


	rand logic [06:00] addr;
	rand bit		   is_read;
	rand logic [07:00] tx_data[];

	`uvm_object_utils_begin(i2c_seq_item)
		`uvm_field_int			(addr		, UVM_ALL_ON)
		`uvm_field_int			(is_read	, UVM_ALL_ON)
		`uvm_field_array_int	(tx_data	, UVM_ALL_ON)
	`uvm_object_utils_end

	constraint c_addr {
		addr dist {
			7'h12			 := 96,
			[7'h00 : 7'h11] :/ 2,
			[7'h13 : 7'h7f] :/ 2
		};
	}

	constraint c_tx_data_size {
		if(is_read) {
			tx_data.size() == 0;
		}
		else {
			tx_data.size() inside {[1:8]};
		}
	}

	function new(string name = "i2c_seq_item");
		super.new(name);
	endfunction

	function string convert2string();
		string str;

		str = $sformatf("addr=0x%02h, is_read=%0d, num_data=%0d\n", addr, is_read, tx_data.size());

		foreach(tx_data[i]) begin
			str = {str, $sformatf("tx_data[%0d]=0x%02h\n", i, tx_data[i])};
		end

		return str;
	endfunction

endclass

class i2c_exp_item extends uvm_sequence_item;

	logic [06:00] addr;
	logic		  rw;
	logic [07:00] data[$];

	`uvm_object_utils_begin(i2c_exp_item)
		`uvm_field_int			(addr	, UVM_ALL_ON)
		`uvm_field_int			(rw		, UVM_ALL_ON)
		`uvm_field_queue_int	(data	, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "i2c_exp_item");
		super.new(name);
	endfunction

	function string convert2string();
		string str;

		str = $sformatf("addr=0x%02h, rw=%0d, num_data=%0d\n", addr, rw, data.size());

		foreach(data[i]) begin
			str = {str, $sformatf("data[%0d]=0x%02h\n", i, data[i])};
		end

		return str;
	endfunction

endclass

class i2c_act_item extends uvm_sequence_item;

	logic [06:00] addr;
	logic		  rw;
	logic		  addr_ack;

	logic [07:00] data[$];
	logic		  data_ack[$];

	logic [07:00] slave_data[$];

	`uvm_object_utils_begin(i2c_act_item)
		`uvm_field_int			(addr		, UVM_ALL_ON)
		`uvm_field_int			(rw			, UVM_ALL_ON)
		`uvm_field_int			(addr_ack	, UVM_ALL_ON)
		`uvm_field_queue_int	(data		, UVM_ALL_ON)
		`uvm_field_queue_int	(data_ack	, UVM_ALL_ON)
		`uvm_field_queue_int	(slave_data	, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "i2c_act_item");
		super.new(name);
	endfunction

	function string convert2string();
		string str;

		str = $sformatf("addr=0x%02h, rw=%0d, addr_ack=%0d, num_data=%0d, num_slave_data=%0d\n",
						addr, rw, addr_ack, data.size(), slave_data.size());

		foreach(data[i]) begin
			str = {str, $sformatf("data[%0d]=0x%02h\n", i, data[i])};
		end

		foreach(data_ack[i]) begin
			str = {str, $sformatf("data_ack[%0d]=%0d\n", i, data_ack[i])};
		end

		foreach(slave_data[i]) begin
			str = {str, $sformatf("slave_data[%0d]=0x%02h\n", i, slave_data[i])};
		end

		return str;
	endfunction

endclass


