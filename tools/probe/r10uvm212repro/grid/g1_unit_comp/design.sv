import uvm_pkg::*;
`include "uvm_macros.svh"
class g1c extends uvm_component;
  `uvm_component_utils(g1c)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass
module top; initial begin end endmodule
