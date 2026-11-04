// § caDelayParamElabFresh164 — a real parameter delay, one net assignment
module top #(parameter real D = 1.5) (input a, output b);
  assign #D b = a;
endmodule
