// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input [4:0] sel);
   logic [31:0] v;
   mod m(.a(v[sel]));
endmodule
