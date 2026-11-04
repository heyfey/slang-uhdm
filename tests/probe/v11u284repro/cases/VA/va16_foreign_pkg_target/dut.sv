// § pkgAliasTdRefNameByParent284
package pk0;
  typedef logic [3:0] b_t;
endpackage
package pk;
  typedef pk0::b_t a_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  pk::a_t z;
  assign z = i;
  assign o = z;
endmodule
