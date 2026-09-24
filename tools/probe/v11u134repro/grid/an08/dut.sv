// § memberAnonUnionAtKeyword134
module top(input logic [7:0] i, output logic [7:0] o);
  typedef struct {
    union { logic [7:0] a; logic [7:0] b; } u;
    logic t;
  } s_t;
  s_t s;
  always_comb begin s.u.a = i; s.t = 1'b0; end
  assign o = s.u.b;
endmodule
