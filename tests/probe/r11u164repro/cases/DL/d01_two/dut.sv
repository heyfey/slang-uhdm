// § caDelayFirstOnly164 — one delay, two net assignments
module top (input a, output b, output c);
  assign #2 b = a, c = ~a;
endmodule
