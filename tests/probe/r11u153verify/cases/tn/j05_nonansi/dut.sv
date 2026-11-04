// § tpDefaultCaLhsUnparented146
module dut #(parameter int W = 4, parameter type T = logic [W-1:0]) (i, o);
  input T i;
  output T o;
  assign o = i;
endmodule
