// § castKeyElabNetNoFile146
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module sub #(parameter s_t P = s_t'{a: 4'h1, b: 4'h2}) (output logic [7:0] o);
  assign o = P;
endmodule
module top(output logic [7:0] x, output logic [7:0] y);
  sub u1(.o(x));
  sub u2(.o(y));
endmodule
