// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
  parameter a_t PP = '0;
endpackage
module dut(output logic [3:0] o);
  assign o = pk::PP;
endmodule
