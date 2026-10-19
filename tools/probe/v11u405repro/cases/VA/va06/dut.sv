// § modUnpackedDimArithRef405
module top (output int o);
  localparam int n = 3;
  localparam int b [n-1:0] = '{default: 5};
  assign o = b[0];
endmodule
