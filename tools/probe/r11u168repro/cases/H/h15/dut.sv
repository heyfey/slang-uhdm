// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [31:0] v, input logic [4:0] i, input logic [4:0] j);
   mod m(.a(v[i+j]));
endmodule
