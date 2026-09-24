// § suSigningNotInSpan130
module top;
  typedef struct packed signed { logic [3:0] a; logic [3:0] b; } T;
  T x;
  assign x = '0;
endmodule
