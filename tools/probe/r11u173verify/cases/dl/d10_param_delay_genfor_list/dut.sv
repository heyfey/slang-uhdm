// § caDelayFirstOnly164 § caDelayParamElabFresh164 — a parameter delay over two net assignments inside a gen-for block
module top #(parameter D = 2) (input [1:0] a, output [1:0] b, output [1:0] c);
  for (genvar i = 0; i < 2; i++) begin : g
    assign #D b[i] = a[i], c[i] = ~a[i];
  end
endmodule
