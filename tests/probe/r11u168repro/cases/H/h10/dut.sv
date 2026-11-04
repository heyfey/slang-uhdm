// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [4:0] sel, input logic [31:0] v, output o);
   mod m(.a(v[sel]));
endmodule
