// § caDelayParamElabFresh164 — a parameter delay inside a gen-if block
module top #(parameter D = 4) (input a, output b);
  if (1) begin : g
    assign #D b = a;
  end
endmodule
