// § caDelayFirstOnly164 — a real delay, two net assignments
module top (input a, output b, output c);
  assign #1.5 b = a, c = ~a;
endmodule
