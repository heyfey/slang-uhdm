// § caDelayParamElabFresh164 — a parameter delay on two separate statements
module top #(parameter D = 3) (input a, output b, output c);
  assign #D b = a;
  assign #D c = ~a;
endmodule
