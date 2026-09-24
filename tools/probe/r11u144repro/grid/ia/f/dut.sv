// § caSelLhsBareDecNoAdjust144
module t;
  localparam int unsigned I = 9;
  logic [5:0] sig;
  assign sig[I-6:I-7] = 7;
endmodule
