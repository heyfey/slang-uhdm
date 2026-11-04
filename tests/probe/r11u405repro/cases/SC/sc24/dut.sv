// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w = 4) (input logic [7:0] i, output logic [7:0] o);
  if (w == 1) begin
    assign o = 1'b1;
  end
  else begin
    assign o = (w) ' (i << 1);
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
