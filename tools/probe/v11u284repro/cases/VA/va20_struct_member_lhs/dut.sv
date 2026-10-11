// § pkgAliasTdRefNameByParent284
package pk;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [1:0] i, output logic [3:0] o);
  pk::a_t z;
  assign z.a = i;
  assign z.b = i;
  assign o = z;
endmodule
