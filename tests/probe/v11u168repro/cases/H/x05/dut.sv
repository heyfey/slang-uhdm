// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [7:0] v, input logic [2:0] i, input logic c);
   mod m(.a(v[c ? i : 3'd0]));
endmodule
