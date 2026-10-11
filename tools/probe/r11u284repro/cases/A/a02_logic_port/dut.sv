// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut import pk::*; (input a_t i, output logic [3:0] o);
  assign o = i;
endmodule
