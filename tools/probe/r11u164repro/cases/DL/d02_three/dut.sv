// § caDelayFirstOnly164 — one delay, three net assignments
module top (input a, output b, output c, output d);
  assign #2 b = a, c = ~a, d = a;
endmodule
