// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(output logic [3:0] o);
  localparam pk::a_t L = 4'd7;
  assign o = L;
endmodule
