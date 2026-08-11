class i2c_base_seq extends uvm_sequence#(i2c_seq_item);
	`uvm_object_utils(i2c_base_seq)

	function new(string name = "i2c_base_seq");
		super.new(name);
	endfunction

	task do_write();
		i2c_seq_item item;
		item = i2c_seq_item::type_id::create("item");
		
		start_item(item);
		if(!item.randomize() with { is_read == 0;}) begin
			`uvm_fatal(get_type_name(), "do_write() Randomize() fail!")
		end
		`uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)
		finish_item(item);
	endtask

	task do_read();
		i2c_seq_item item;
		item = i2c_seq_item::type_id::create("item");

		start_item(item);
		if(!item.randomize() with { is_read == 1;}) begin
			`uvm_fatal(get_type_name(), "do_read() Randomize() fail!")
		end
		`uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)

		finish_item(item);
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
			if($urandom_range(0,1)) begin
				do_write();
			end
			else begin
				do_read();
			end
		end

	endtask

endclass

