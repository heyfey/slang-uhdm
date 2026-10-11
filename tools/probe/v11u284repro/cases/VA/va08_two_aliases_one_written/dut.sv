// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
  typedef b_t c_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  pk::a_t z;
  pk::c_t y;
  assign z = i;
  always_comb y = z;
  assign o = y;
endmodule
