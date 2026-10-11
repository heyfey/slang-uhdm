// § pkgAliasTdRefNameByParent284
package pk;
  typedef struct packed { logic [1:0] x; logic [1:0] y; } b_t;
  typedef b_t a_t;
  a_t pv;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = i ^ pk::pv;
endmodule
