// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module sub(input logic [3:0] i, output logic [3:0] o);
  pk::a_t z;
  assign z = i;
  assign o = z;
endmodule
module dut(input logic [3:0] i, output logic [3:0] o);
  if (1) begin : g
    sub u(.i(i), .o(o));
  end
endmodule
