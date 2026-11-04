// § tpDefaultCaLhsUnparented146
module sub #(parameter int W = 4, parameter type T = logic [W-1:0]) (input T i, output T o);
  assign o = i;
endmodule
module dut(input logic [7:0] i, output logic [7:0] o);
  sub #(.T(logic [7:0])) u(.i(i), .o(o));
endmodule
