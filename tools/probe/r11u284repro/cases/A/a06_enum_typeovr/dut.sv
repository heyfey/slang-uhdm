// § pkgAliasTdRefNameByParent284
package pk;
  typedef enum logic [3:0] { E0, E1 } b_t;
  typedef b_t a_t;
endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut(input logic [3:0] a, output logic o);
  child #(.T(pk::a_t)) u (.a(a), .o(o));
endmodule
