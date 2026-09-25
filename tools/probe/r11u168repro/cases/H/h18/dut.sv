// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [31:0] v, input logic [4:0] i);
   mod m[1:0] (.a(v[i]));
endmodule
