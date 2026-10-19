// § typedParamXzLitSize407
module top(output int o);
  parameter int ma = 4'bz;
  parameter int mb = 'x;
  localparam logic [7:0] mc = 1'bx;
  assign o = ma + mb + mc;
endmodule
