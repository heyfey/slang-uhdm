// § caDelayFirstOnly164 § caDelayParamElabFresh164 — a localparam delay derived from a parameter, two net assignments
module top #(parameter D = 2) (input a, output b, output c);
  localparam D2 = D * 2;
  assign #D2 b = a, c = ~a;
endmodule
