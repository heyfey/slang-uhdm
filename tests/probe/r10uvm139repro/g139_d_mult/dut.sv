// r10uvm139 arm D — MULTIPLICITY: one parameterised module instantiated once,
// twice and three times, plus a package class used from each, so that the DEF
// listing and every ELAB copy of the same subroutine are scored separately.
// Names deliberately unlike arms A, B and C.
package Anvil139;
  class Hammer139;
    function void hmNoParen139;
      string  ea;
      static string eb;
      automatic string ec;
      string  ed = "d";
      static string ee = "e";
      ea = eb;
    endfunction
    task hmTaskIo139;
      input int ef;
      int       eg;
      static int eh;
      eg = eh;
    endtask
  endclass

  function void pkgFn139;
    int       ei;
    static int ej;
    int       ek = 4;
    ei = ej;
  endfunction
endpackage

module Rivet139 #(parameter int W139 = 1) (input logic clk139);
  import Anvil139::*;

  function void rvNoParen139;
    logic [W139-1:0] fa;
    static logic [W139-1:0] fb;
    automatic logic [W139-1:0] fc;
    logic [W139-1:0] fd = '0;
    static logic [W139-1:0] fe = '0;
    fa = fb;
  endfunction

  task rvTaskIo139;
    input int ff;
    int       fg;
    static int fh;
    fg = fh;
  endtask

  initial begin
    Hammer139 h139 = new();
    rvNoParen139();
    rvTaskIo139(0);
    h139.hmNoParen139();
    pkgFn139();
  end
endmodule

module Press139;
  logic clk139;
  Rivet139 #(.W139(1)) one139 (.clk139(clk139));
endmodule

module Bellows139;
  logic clk139;
  Rivet139 #(.W139(2)) two139a (.clk139(clk139));
  Rivet139 #(.W139(3)) two139b (.clk139(clk139));
endmodule

module Crucible139;
  logic clk139;
  Rivet139 #(.W139(4)) three139a (.clk139(clk139));
  Rivet139 #(.W139(5)) three139b (.clk139(clk139));
  Rivet139 #(.W139(6)) three139c (.clk139(clk139));
endmodule
