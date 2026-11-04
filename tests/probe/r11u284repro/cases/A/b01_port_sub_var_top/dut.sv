// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module sub(input pk::a_t p, output logic [3:0] o);
  assign o = p;
endmodule
module dut(output logic [3:0] o);
  pk::a_t z;
  assign z = '0;
  sub u (.p(z), .o(o));
endmodule
