// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  import pk::b_t;
  pk::a_t z;
  b_t y;
  always_comb z = i;
  always_comb y = z;
  assign o = y;
endmodule
