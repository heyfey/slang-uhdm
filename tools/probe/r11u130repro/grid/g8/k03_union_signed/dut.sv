// § suSigningNotInSpan130
module top;
  union packed signed { logic [3:0] a; logic [3:0] b; } u;
  assign u = '0;
endmodule
