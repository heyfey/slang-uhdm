// § caDelayParamElabFresh164 — a localparam delay
module top (input a, output b);
  localparam D = 2;
  assign #D b = a;
endmodule
