// § tpDefaultCaLhsUnparented146
module dut #(parameter int W = 4, parameter type T = logic [W-1:0]) (input T i, output T o);
  if (1) begin : g
    assign o = i;
  end
endmodule
