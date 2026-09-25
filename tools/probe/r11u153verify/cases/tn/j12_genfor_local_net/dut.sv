// § tpDefaultCaLhsUnparented146 law tpDefaultCaGenLocalLhsKeeps153v
module dut #(parameter int W = 4, parameter type T = logic [W-1:0]) (input logic [3:0] i, output logic [3:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    T w;
    assign w = i;
    assign o[k] = w;
  end
endmodule
