// § pkgAliasTdRefNameByParent284
package pk;
  typedef struct packed { logic [1:0] x; logic [1:0] y; } b_t;
  typedef b_t a_t;
  parameter a_t PP = '0;
endpackage
module dut(output logic [3:0] o);
  assign o = pk::PP;
endmodule
