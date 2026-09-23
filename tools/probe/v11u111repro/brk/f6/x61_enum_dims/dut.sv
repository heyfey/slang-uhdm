package pk;
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
endpackage
module child #(parameter type T = logic) (input T a, output logic o);
  assign o = ^a;
endmodule
module dut (input logic [3:0] a, output logic o);
  child #(.T(pk::e_t [1:0])) u (.a(a), .o(o));
endmodule
