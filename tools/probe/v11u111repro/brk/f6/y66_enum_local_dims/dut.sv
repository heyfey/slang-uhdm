typedef enum logic [1:0] { E0, E1, E2 } e_t;
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [5:0] a, output logic o);
  child #(.T(e_t [2:0])) u (.a(a), .o(o));
endmodule
