// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module sub(input pk::a_t p, output logic [3:0] o);
  assign o = p;
endmodule
module dut(input pk::a_t p, output logic [3:0] o);
  sub u (.p(p), .o(o));
endmodule
