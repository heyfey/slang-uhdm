// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module mid(input logic [7:0] v, input logic [2:0] sel);
  mod m(.a(v[sel]));
endmodule
module dut(input logic [7:0] v, input logic [2:0] sel);
  mid u(.v(v), .sel(sel));
endmodule
