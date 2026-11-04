// § castKeyElabNetNoFile146
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module top(output logic [7:0] x);
  localparam s_t L = s_t'{a: 4'h3, b: 4'h4};
  assign x = L;
endmodule
