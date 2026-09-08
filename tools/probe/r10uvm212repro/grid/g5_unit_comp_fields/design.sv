import uvm_pkg::*;
`include "uvm_macros.svh"
class g5c extends uvm_component;
  int unsigned f5;
  `uvm_component_utils_begin(g5c)
    `uvm_field_int(f5, UVM_ALL_ON)
  `uvm_component_utils_end
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass
module top; initial begin end endmodule
