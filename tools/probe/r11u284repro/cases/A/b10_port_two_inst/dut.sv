// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module sub(input pk::a_t p, output logic [3:0] o);
  assign o = p;
endmodule
module dut(input logic [3:0] i, output logic [3:0] o, output logic [3:0] o2);
  sub u1 (.p(i), .o(o));
  sub u2 (.p(i), .o(o2));
endmodule
