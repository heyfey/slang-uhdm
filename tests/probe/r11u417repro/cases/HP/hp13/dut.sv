// § hierSelParenBoundPretty417
module top #(parameter int P = 34, parameter int V = 32) (output logic [33:0] o);
  typedef struct packed { logic [63:0] a; } r_s;
  r_s d;
  assign o = d.a[((P > V) ? V-1 : P-1):0];
endmodule
