// § modUnpackedDimArithRef405
module top #(parameter int n = 2, parameter int a [n] = '{default: 2}) (output int o);
  assign o = a[0];
endmodule
