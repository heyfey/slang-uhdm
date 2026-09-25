// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module mid(input logic [7:0] v, input logic [2:0] i);
   mod m(.a(v[i]));
endmodule
module dut(input logic [7:0] v, input logic [2:0] i);
   mid u(.v(v), .i(i));
endmodule
