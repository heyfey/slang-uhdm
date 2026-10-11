// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module top2(input logic [3:0] i);
  pk::a_t z;
  assign z = i;
endmodule
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
