package g8p;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class g8c #(type T = int) extends uvm_component;
    `uvm_component_param_utils(g8c#(T))
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
endpackage
module top; initial begin end endmodule
