// § genCaReplWholeFold78 (decode only, ground B's ModuleEmit: Earlgrey #600811 / #530951) (localparam literal count)
module m #(parameter bit E = 1) (output logic [7:0] q);
  localparam int L = 8;
  if (E) begin : g
    logic [7:0] w;
    assign w = {L{1'b1}};
    assign q = w;
  end
endmodule
module top(output logic [7:0] q);
  m u (.*);
endmodule
