// § genvarCastTgtUnsupTs411
module top (input logic [7:0] x, output logic [7:0] y [2]);
  localparam int K = 4;
  for (genvar i = 1; i < 3; i++) begin : g
    localparam int L = i + 1;
    assign y[i-1] = L'(x) + K'(x);
  end
endmodule
