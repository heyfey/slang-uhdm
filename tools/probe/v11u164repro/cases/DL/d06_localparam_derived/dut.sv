// § caDelayParamElabFresh164 — a localparam delay derived from a parameter, overridden child
module ch #(parameter D = 2) (input a, output b);
  localparam D2 = D * 2;
  assign #D2 b = a;
endmodule
module top (input a, output b);
  ch #(.D(5)) u(a, b);
endmodule
