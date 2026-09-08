package g6p;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class g6c extends uvm_component;
    int unsigned f6;
    `uvm_component_utils_begin(g6c)
      `uvm_field_int(f6, UVM_ALL_ON)
    `uvm_component_utils_end
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
endpackage
module top; initial begin end endmodule
