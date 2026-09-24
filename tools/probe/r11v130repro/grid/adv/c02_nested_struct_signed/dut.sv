// § suSigningNotInSpan130
module top;
  typedef struct packed { struct packed signed { logic [3:0] a; } inner; logic b; } T;
  T x;
  struct packed { union packed signed { logic [3:0] a; logic [3:0] b; } u; logic c; } y;
  assign x = '0;
  assign y = '0;
endmodule
