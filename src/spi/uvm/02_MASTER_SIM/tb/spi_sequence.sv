class spi_base_seq extends uvm_sequence #(spi_seq_item);
	`uvm_object_utils(spi_base_seq)


	function new(string name = "spi_base_seq");
		super.new(name);
	endfunction

	task do_transfer();
		spi_seq_item item;


		item = spi_seq_item::type_id::create("item");

		start_item(item);

		if(!item.randomize()) begin
			`uvm_fatal(get_type_name(), "do_transfer() randomize() fail!")
		end

		`uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)

		finish_item(item);
	endtask

endclass


class spi_rand_seq extends spi_base_seq;
	`uvm_object_utils(spi_rand_seq)


	int num_loop = 1000;

	function new(string name = "spi_rand_seq");
		super.new(name);
	endfunction

	virtual task body();
		repeat(num_loop) begin
			do_transfer();
		end
	endtask

endclass
