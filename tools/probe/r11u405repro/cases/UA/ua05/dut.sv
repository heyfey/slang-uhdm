// § modUnpackedDimArithRef405
module top #(parameter int n = 2) (output int o);
  localparam int a [n-1:0] = '{default: 2};
  assign o = a[0];
endmodule
