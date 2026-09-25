// § tpDefaultCaLhsUnparented146
module dut #(parameter int W = 4, parameter int X = 1, parameter type T = logic [W+X-1:X]) (input T i, output T o);
  assign o = i;
endmodule
