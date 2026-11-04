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
module dut(output logic [3:0] o);
  sub u (.o(o));
endmodule
