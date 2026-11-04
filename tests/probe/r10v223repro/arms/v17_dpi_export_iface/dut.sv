// v17 — an interface that imports a package AND carries the shapes earlier
// passes fenced: a DPI import/export, a clocking block, an assertion and a
// covergroup.  The hoist must not disturb any of them.
package pv17;
  int hv17 = 1;
  string hs17 = "h";
endpackage

interface if_v17 (input logic clk);
  import pv17::*;
  import "DPI-C" function int dpi_f17(input int a);
  export "DPI-C" function dpi_g17;
  function int dpi_g17(input int a); return a; endfunction
  logic own_v17;
  logic req17, ack17;
  clocking cb17 @(posedge clk);
    input own_v17;
  endclocking
  modport mp17 (clocking cb17);
  a17: assert property (@(posedge clk) req17 |-> ack17);
  covergroup cg17 @(posedge clk);
    c17: coverpoint own_v17;
  endgroup
endinterface

module top_v17 (input logic clk);
  if_v17 u_if (.clk(clk));
endmodule
