// § defGenSelRefChainName287
module m #(parameter int D = 4) (input logic [31:0] din, output logic [31:0] o);
  if (D != 0) begin : h
    localparam int K = 3;
    assign o = {29'b0, din[0 +: K-1]};
  end
endmodule
