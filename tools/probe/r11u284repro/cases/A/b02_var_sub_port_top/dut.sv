// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module sub(output logic [3:0] o);
  pk::a_t z;
  assign z = '0;
  assign o = z;
endmodule
module dut(input pk::a_t p, output logic [3:0] o, output logic [3:0] o2);
  sub u (.o(o));
  assign o2 = p;
endmodule
