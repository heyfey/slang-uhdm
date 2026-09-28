module top(output logic [1:0] o);
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  localparam s_t P = '{a: 2'b10, b: 1'b1};
  assign o = P.a;
endmodule
