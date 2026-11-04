// § modUnpackedDimArithRef405
module top (output int o);
  localparam int n = 2;
  localparam int a [n-1:0] = '{default: 2};
  assign o = a[0];
endmodule
