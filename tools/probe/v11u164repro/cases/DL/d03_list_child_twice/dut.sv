// § caDelayFirstOnly164 — a delay list in a child instantiated twice
module ch (input a, output b, output c);
  assign #3 b = a, c = ~a;
endmodule
module top (input a, output b1, c1, b2, c2);
  ch u1(a, b1, c1);
  ch u2(.a(a), .b(b2), .c(c2));
endmodule
