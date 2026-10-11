// § pkgAliasTdRefNameByParent284
package pk;
  localparam int W = 6;
  typedef logic [W-1:0] b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [5:0] i, output logic [5:0] o);
  pk::a_t z;
  assign z = i;
  assign o = z;
endmodule
