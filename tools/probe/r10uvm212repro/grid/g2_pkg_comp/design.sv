package g2p;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class g2c extends uvm_component;
    `uvm_component_utils(g2c)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
endpackage
module top; initial begin end endmodule
