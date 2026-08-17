class spi_seq_item extends uvm_sequence_item;


	rand logic [07:00] tx_data;

	`uvm_object_utils_begin(spi_seq_item)
		`uvm_field_int(tx_data, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "spi_seq_item");
		super.new(name);
	endfunction

	function string convert2string();
		string str;

		str = $sformatf("tx_data=0x%02h", tx_data);

		return str;
	endfunction

endclass


class spi_exp_item extends uvm_sequence_item;


	logic [07:00] tx_data;

	`uvm_object_utils_begin(spi_exp_item)
		`uvm_field_int(tx_data, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "spi_exp_item");
		super.new(name);
	endfunction

	function string convert2string();
		string str;

		str = $sformatf("tx_data=0x%02h", tx_data);

		return str;
	endfunction

endclass


class spi_act_item extends uvm_sequence_item;


	logic [07:00] bus_tx_data;
	logic [07:00] bus_rx_data;

	logic [07:00] master_rx_data;
	logic [07:00] slv_rx_data;

	`uvm_object_utils_begin(spi_act_item)
		`uvm_field_int(bus_tx_data,    UVM_ALL_ON)
		`uvm_field_int(bus_rx_data,    UVM_ALL_ON)
		`uvm_field_int(master_rx_data, UVM_ALL_ON)
		`uvm_field_int(slv_rx_data,    UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "spi_act_item");
		super.new(name);
	endfunction

	function string convert2string();
		string str;

		str = $sformatf("bus_tx=0x%02h, bus_rx=0x%02h, master_rx=0x%02h, slv_rx=0x%02h",
						bus_tx_data, bus_rx_data, master_rx_data, slv_rx_data);

		return str;
	endfunction

endclass
