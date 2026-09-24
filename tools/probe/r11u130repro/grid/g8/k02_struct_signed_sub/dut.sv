// § suSigningNotInSpan130
module sub;
  struct packed signed { logic [3:0] a; logic [3:0] b; } s;
  assign s = '0;
endmodule
module top;
  sub u();
endmodule
