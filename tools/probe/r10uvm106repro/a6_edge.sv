// a6: grammar edges and the UVM shape (package param imported by a class)
`define MHEX 'h1a
`define MBIN 'b101
package a6_pkg;
  parameter E_TB0 = 'b0;
  parameter E_TB1 = 'b1;
  parameter E_TBB0 = 'B0;
  parameter E_TBB1 = 'B1;
  parameter E_TH0 = 'h0;
  parameter E_TD0 = 'd0;
  parameter E_US  = 'hf_000_000;
  parameter E_MAC = `MHEX;
  parameter E_MACB = `MBIN;
  parameter E_UP  = 'HF;
  parameter E_BIGH = 'h123456789abcdef0123;
endpackage
package a6_use;
  import a6_pkg::*;
  class a6_cls;
    function int f(); return E_TH0 + E_MAC + E_TB0; endfunction
  endclass
  parameter E_LOCAL = 'h2b;
endpackage
module a6_top;
  import a6_use::*;
  a6_cls c;
  initial $display(E_LOCAL);
endmodule
