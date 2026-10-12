// § tpUseSigBindsTpObj291
package pk; typedef struct packed { logic [1:0] a; logic b; } s_t; endpackage
module child #(parameter type T = logic) (input logic [2:0] a, output logic o);
  T v;
  assign v = a;
  assign o = v.b;
endmodule
module dut (input logic [2:0] a, output logic o);
  child #(.T(pk::s_t)) u (.a(a), .o(o));
endmodule
