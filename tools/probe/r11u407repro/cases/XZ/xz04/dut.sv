// § typedParamXzLitSize407
module top(output int o);
  parameter int ma = 1'b1;
  parameter int mb = 2'b0x;
  assign o = ma + mb;
endmodule
