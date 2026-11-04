// § genvarCastTgtUnsupTs411
module top (input logic [7:0] x, output logic [7:0] y [2]);
  for (genvar i = 1; i < 3; i++) begin : g
    assign y[i-1] = (i+1)'(x);
  end
endmodule
