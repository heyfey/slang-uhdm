// § defGenSelRefChainName287
module m #(parameter int D = 4) (input logic [31:0] din, input logic [31:0] idx, output logic [31:0] o);
  if (D != 0) begin : h
    localparam int PN = 3;
    assign o = {28'b0, din[idx[PN:1] +: 4]};
  end
endmodule
