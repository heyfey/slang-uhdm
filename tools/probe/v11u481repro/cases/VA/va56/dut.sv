// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; function automatic int f2(input bit b); return b; endfunction task tk2(input bit b); endtask endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module sub; task tk(input bit b); endtask endmodule
module top; import t::*; sub s1();
  initial begin vt_t g; s1.tk(g == null); end
endmodule
