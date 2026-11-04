// § caSelLhsBareDecNoAdjust144
module t;
  logic [5:0] sig;
  logic [3:0] a;
  assign {sig[1], a} = 3;
endmodule
