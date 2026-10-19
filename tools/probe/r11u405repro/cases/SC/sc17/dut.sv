// § undefParamCastSizeTs405
module top; endmodule
module m #(parameter w) (input logic [7:0] i, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] a);
    return w'(a);
  endfunction
  assign o = f(i);
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
