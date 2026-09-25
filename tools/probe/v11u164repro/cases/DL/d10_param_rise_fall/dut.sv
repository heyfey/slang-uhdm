// § caDelayParamElabFresh164 — a parameter rise/fall delay pair
module top #(parameter R = 2, F = 3) (input a, output b);
  assign #(R, F) b = a;
endmodule
