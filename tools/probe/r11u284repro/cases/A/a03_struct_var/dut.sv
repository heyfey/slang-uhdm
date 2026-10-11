// § pkgAliasTdRefNameByParent284
package pk;
  typedef struct packed { logic [1:0] x; logic [1:0] y; } b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  pk::a_t v;
  assign v = i;
  assign o = v;
endmodule
