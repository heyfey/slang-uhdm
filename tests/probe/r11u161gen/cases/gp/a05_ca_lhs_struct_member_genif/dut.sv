// r11u161 gen path: cont-assign LHS inside a gen-if block, struct variable member (SEL)
module top(input logic [3:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] f; logic [3:0] g; } s_t;
  s_t s;
  if (1) begin : G
    assign s.f = a;
    assign s.g = ~a;
  end
  assign o = s;
endmodule
