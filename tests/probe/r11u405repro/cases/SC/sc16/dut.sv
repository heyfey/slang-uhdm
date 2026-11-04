// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w, parameter n = 2) (output logic [7:0] o [n], output logic [7:0] p);
  for (genvar i = 0; i < n; i++) begin : g
    assign o[i] = w ' (0);
  end
  assign p = w'(1);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
