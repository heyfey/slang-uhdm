// § genCaReplWholeFold78 (decode only, ground B's ModuleEmit: Earlgrey #600811 / #530951) (localparam equal to an overridden header parameter)
module m #(parameter int W = 4, parameter bit E = 1) (output logic [7:0] q);
  localparam int L = W;
  if (E) begin : g
    logic [7:0] w;
    assign w = {L{1'b1}};
    assign q = w;
  end
endmodule
module top(output logic [7:0] q);
  m #(.W(8)) u (.*);
endmodule
