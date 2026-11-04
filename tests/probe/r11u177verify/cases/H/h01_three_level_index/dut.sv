// § hcSelIdxInstName168
module mod(input logic a);
endmodule
module dut(input logic [7:0] v, input logic [2:0] w [4], input logic [1:0] k);
  mod m(.a(v[w[k[0]]]));
endmodule
