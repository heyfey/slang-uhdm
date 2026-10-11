// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [1:0] i, output logic [3:0] o);
  pk::a_t z;
  assign z[1:0] = i;
  assign z[3:2] = i;
  assign o = z;
endmodule
