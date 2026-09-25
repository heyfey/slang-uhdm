// § tpDefaultCaLhsUnparented146
module dut #(parameter int W = 4, parameter type T = logic [W-1:0]) (input T i, output T o);
  assign o[0] = i[0];
  assign o[W-1:1] = '0;
endmodule
