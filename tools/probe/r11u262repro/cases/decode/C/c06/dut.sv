// § genCaReplWholeFold78 (decode only, ground B's ModuleEmit: Earlgrey #600811 / #530951) (module-body target, header parameter count, whole right side)
module m #(parameter int W = 4, parameter bit E = 1) (output logic [7:0] q);
  logic [7:0] w;
  if (E) begin : g
    assign w = {W{1'b1}};
  end
  assign q = w;
endmodule
module top(output logic [7:0] q);
  m #(.W(8)) u (.*);
endmodule
