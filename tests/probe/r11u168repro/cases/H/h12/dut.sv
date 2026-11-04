// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [4:0] sel, input logic [31:0] v);
   mod m(.a(v[sel] & v[0]));
endmodule
