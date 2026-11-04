// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [7:0] v, input logic [2:0] i [0:1]);
   mod m(.a(v[i[1]]));
endmodule
