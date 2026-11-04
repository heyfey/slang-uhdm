// § genvarCastTgtUnsupTs411
module top (input logic [7:0] x, output logic [7:0] y [2][2]);
  for (genvar i = 1; i < 3; i++) begin : g
    for (genvar j = 1; j < 3; j++) begin : h
      assign y[i-1][j-1] = (i)'(x) + j'(x);
    end
  end
endmodule
