package g7p;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class g7pc extends uvm_component;
    `uvm_component_utils(g7pc)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
endpackage
import uvm_pkg::*;
class g7uc extends uvm_component;
  `uvm_component_utils(g7uc)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
endclass
module top; initial begin end endmodule
