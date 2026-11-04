// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(input logic i, output logic [3:0] o);
  pk::a_t z;
  assign z[0] = i;
  assign z[3:1] = '0;
  assign o = z;
endmodule
