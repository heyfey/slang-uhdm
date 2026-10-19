// § genvarCastTgtUnsupTs411
module top (input logic [7:0] x, output logic [7:0] y [2]);
  for (genvar i = 1; i < 3; i++) begin : g
    localparam int L = i + 2;
    assign y[i-1] = (L)'(x);
  end
endmodule
