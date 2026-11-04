// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [31:0] v, input logic [1:0][4:0] idx);
   mod m(.a(v[idx[1]]));
endmodule
