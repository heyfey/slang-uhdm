// § tpDefaultCaLhsUnparented146
module dut #(parameter int W = 4) (input logic [3:0] i, output logic [3:0] o);
  localparam type T = logic [W-1:0];
  T v;
  assign v = i;
  assign o = v;
endmodule
