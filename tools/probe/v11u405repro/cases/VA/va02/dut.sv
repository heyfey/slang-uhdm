// § modUnpackedDimArithRef405
module top #(parameter int n = 2, parameter int a [0:n-1] = '{3, 4}) (output int o);
  assign o = a[1];
endmodule
