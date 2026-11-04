// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [3:0] mm [4], input logic [1:0] i, input logic [1:0] j);
  mod m(.a(mm[i][j]));
endmodule
