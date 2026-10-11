// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut import pk::*; (input logic [3:0] i, output logic [3:0] o);
  a_t v;
  assign v = i;
  assign o = v;
endmodule
