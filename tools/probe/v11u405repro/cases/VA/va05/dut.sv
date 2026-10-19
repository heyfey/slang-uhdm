// § modUnpackedDimArithRef405
module top #(parameter int n = 2) (output int o);
  localparam int b [n*2] = '{default: 5};
  localparam int c [n+1] = '{default: 6};
  assign o = b[0] + c[0];
endmodule
