// § caDelayFirstOnly164 — drive strength and a delay, two net assignments
module top (input a, output b, output c);
  assign (strong0, weak1) #1 b = a, c = ~a;
endmodule
