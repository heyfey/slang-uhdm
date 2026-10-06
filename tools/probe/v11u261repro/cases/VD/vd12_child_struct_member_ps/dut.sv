// § genChildParentAtBirth261
typedef struct packed { logic [31:0] a; logic b; } s_t;
module leaf (input s_t s, output logic [15:0] o);
  assign o = s.a[31:16];
endmodule
module mid (input s_t s, output logic [15:0] o);
  if (1) begin : g
    leaf l (.s(s), .o(o));
  end
endmodule
module top;
  s_t s; logic [15:0] o;
  mid m (.s(s), .o(o));
endmodule
