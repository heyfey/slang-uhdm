// § caDelayFirstOnly164 — one delay, one net assignment (control)
module top (input a, output b);
  assign #2 b = a;
endmodule
