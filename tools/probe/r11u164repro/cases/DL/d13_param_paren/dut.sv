// § caDelayParamElabFresh164 — a parenthesised parameter delay (control: pass 90 abstains)
module top #(parameter D = 3) (input a, output b);
  assign #(D) b = a;
endmodule
