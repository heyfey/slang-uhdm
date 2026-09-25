// § caDelayParamElabFresh164 — a delay expression over a parameter (control)
module top #(parameter D = 3) (input a, output b);
  assign #(D+1) b = a;
endmodule
