// § tpDefaultCaLhsUnparented146 law tpDefaultCaGenLocalLhsKeeps153v (control)
module dut #(parameter int W = 4, parameter type T = logic [W-1:0]) (input T i, output T o);
  if (1) begin : g
    T w;
    assign w = i;
  end
  assign o = g.w;
endmodule
