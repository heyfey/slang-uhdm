// § hcSelIdxInstName168
module mod(input logic [1:0] a);
endmodule
module dut(input logic [4:0] sel, input logic [31:0] v);
   mod m(.a(v[sel+:2]));
endmodule
