// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  pk::a_t z;
  if (1) begin : g
    assign z = i;
  end
  assign o = z;
endmodule
