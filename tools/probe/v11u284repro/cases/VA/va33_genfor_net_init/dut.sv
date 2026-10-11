// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    wire pk::a_t z = i;
    assign o[k] = z;
  end
endmodule
