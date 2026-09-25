// § tpDefaultCaLhsUnparented146
module dut #(parameter int N = 2, parameter int W = 4, parameter type T = logic [N-1:0][W-1:0]) (input T i, output T o);
  assign o = i;
endmodule
