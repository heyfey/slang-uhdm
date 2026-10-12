// § tpUseSigBindsTpObj291
typedef struct packed { logic [1:0] a; logic b; } s_t;
module child #(parameter type T = logic) (input logic [2:0] i, output logic o);
  T v;
  assign v = i;
  assign o = ^v;
endmodule
module dut (input logic [2:0] i, output logic o);
  child #(.T(s_t)) u (.i(i), .o(o));
endmodule
