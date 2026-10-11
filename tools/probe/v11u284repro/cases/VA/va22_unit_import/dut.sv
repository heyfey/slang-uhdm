// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
import pk::*;
module dut(input logic [3:0] i, output logic [3:0] o);
  a_t z;
  always_comb z = i;
  assign o = z;
endmodule
