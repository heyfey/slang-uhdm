// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut #(parameter P = 3) (input logic [31:0] v);
   mod m(.a(v[P]));
endmodule
