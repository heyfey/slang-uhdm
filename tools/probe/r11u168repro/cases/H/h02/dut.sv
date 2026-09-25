// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input int sel);
   logic [31:0] v;
   mod m(.a(v[sel]));
endmodule
