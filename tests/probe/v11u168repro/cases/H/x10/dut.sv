// § hcSelIdxInstName168
module mod(input logic [3:0] a);
endmodule
module dut(input logic [3:0] v [0:3], input logic [1:0] i);
   mod m(.a(v[i]));
endmodule
