// § hcSelIdxInstName168
module mod(input logic a, input logic b);
endmodule
module dut(input logic [31:0] v, input logic [4:0] i);
   mod m(v[i], v[i-1]);
endmodule
