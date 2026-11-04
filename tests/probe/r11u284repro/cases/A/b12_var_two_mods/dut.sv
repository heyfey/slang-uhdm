// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module sub(output logic [3:0] o);
  pk::a_t z;
  assign z = '1;
  assign o = z;
endmodule
module dut(output logic [3:0] o, output logic [3:0] o2);
  pk::a_t y;
  assign y = '0;
  sub u (.o(o));
  assign o2 = y;
endmodule
