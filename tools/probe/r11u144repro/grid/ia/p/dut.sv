// § caSelLhsBareDecNoAdjust144
module c(output logic [5:0] sig);
  assign sig[2] = 3;
endmodule
module t;
  logic [5:0] w;
  c u(.sig(w));
endmodule
