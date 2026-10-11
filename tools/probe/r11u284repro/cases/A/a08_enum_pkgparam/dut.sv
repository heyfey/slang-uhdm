// § pkgAliasTdRefNameByParent284
package pk;
  typedef enum logic [3:0] { E0, E1 } b_t;
  typedef b_t a_t;
  parameter a_t PP = '0;
endpackage
module dut(output logic [3:0] o);
  assign o = pk::PP;
endmodule
