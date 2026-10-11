// § pkgAliasTdRefNameByParent284
package pk;
  typedef enum logic [3:0] { E0, E1 } b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  pk::a_t v;
  assign v = i;
  assign o = v;
endmodule
