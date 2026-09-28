// § genCaCastRhsRefUnnamed198: a type-parameter cast of a member select, a size cast over an operation with a part select, in a for-generate select target
module top #(parameter type T = logic [2:0]) (input logic [3:0] b, input logic [2:0] q [2], output logic [2:0] y [2], output logic [2:0] z [2]);
  typedef struct packed { logic [2:0] a; logic c; } s_t;
  s_t s;
  assign s = b;
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = T'(s.a);
    assign z[i] = 3'(q[i] ^ b[2:0]);
  end
endmodule
