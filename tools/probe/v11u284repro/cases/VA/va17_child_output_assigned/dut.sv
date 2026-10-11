// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module sub(input logic [3:0] i, output pk::a_t o);
  assign o = i;
endmodule
module dut(input logic [3:0] i, output logic [3:0] o);
  sub u(.i(i), .o(o));
endmodule
