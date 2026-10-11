// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
  typedef a_t c_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  pk::c_t z;
  assign z = i;
  assign o = z;
endmodule
