// § tpDefaultCaLhsUnparented146
module dut #(parameter int W = 4, parameter type T = logic [W-1:0]) (input logic [3:0] i, output logic [3:0] o);
  T v;
  assign v = i;
  assign o = v;
endmodule
