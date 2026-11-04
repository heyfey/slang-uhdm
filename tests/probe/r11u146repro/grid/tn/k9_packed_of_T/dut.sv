// § tpDefaultCaLhsUnparented146
module dut #(parameter int W = 4, parameter type T = logic [W-1:0]) (input T [1:0] i, output T [1:0] o);
  assign o = i;
endmodule
