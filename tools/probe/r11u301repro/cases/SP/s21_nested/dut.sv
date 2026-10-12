// § caSelLhsParamReuseAnyEnc301
module leaf #(parameter int Z = 5)();
  logic [7:0] arr[2];
  assign arr[0] = Z;
endmodule
module mid #(parameter int W = 4)();
  leaf #(.Z(W)) l();
endmodule
module dut;
  mid #(.W(8)) m0();
endmodule
