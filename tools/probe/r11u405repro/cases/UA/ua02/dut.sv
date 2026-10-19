// § modUnpackedDimArithRef405
module top; endmodule
module m #(parameter int n = 2, parameter int a [n-1:0] = '{default: 2}) (output int o);
  assign o = a[0];
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
