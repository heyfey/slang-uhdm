// § caDelayParamElabFresh164 — a parameter delay, one net assignment
module top #(parameter D = 3) (input a, output b);
  assign #D b = a;
endmodule
