// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [7:0] i, output logic [7:0] o);
  pk::a_t z, y;
  assign {z, y} = i;
  assign o = {z, y};
endmodule
