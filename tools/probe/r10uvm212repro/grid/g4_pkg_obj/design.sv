package g4p;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class g4o extends uvm_object;
    `uvm_object_utils(g4o)
    function new(string name = "g4o"); super.new(name); endfunction
  endclass
endpackage
module top; initial begin end endmodule
