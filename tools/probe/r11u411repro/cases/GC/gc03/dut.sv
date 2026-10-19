// § genvarCastTgtUnsupTs411
module top (input logic [7:0] x, output logic [7:0] y [3]);
  for (genvar i = 1; i < 4; i++) begin : g
    assign y[i-1] = ((i))'(x) + 1;
  end
endmodule
