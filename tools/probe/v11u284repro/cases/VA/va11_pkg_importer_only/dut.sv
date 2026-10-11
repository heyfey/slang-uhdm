// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
package p2;
  import pk::*;
  localparam int K = 1;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  pk::a_t z;
  always_comb z = i;
  assign o = z;
endmodule
