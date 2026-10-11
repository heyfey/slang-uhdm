// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module sub #(parameter pk::a_t M = '0) (output logic [3:0] o);
  assign o = M;
endmodule
module dut(output logic [3:0] o, output logic [3:0] o2);
  pk::a_t z;
  assign z = 4'd3;
  sub #(.M(4'd5)) u (.o(o));
  assign o2 = z;
endmodule
