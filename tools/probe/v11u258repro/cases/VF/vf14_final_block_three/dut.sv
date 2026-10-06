// § forMultiInitAssign258 (three initializers in a final block, one a member, one a part select)
module m; typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t; s_t s; int i; logic [7:0] w;
  final begin for (s.b = 0, i = 0, w[1:0] = 2'd3; i < 4; i++) w = s.b; end
endmodule
module top; m u(); endmodule
