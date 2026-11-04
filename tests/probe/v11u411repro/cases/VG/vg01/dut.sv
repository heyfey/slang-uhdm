// § genvarCastTgtUnsupTs411
module top (input logic [7:0] x, output logic [7:0] y [4]);
  genvar i;
  for (i = 1; i < 3; i++) begin : g
    assign y[i] = i'(x);
  end
endmodule
