// § hpElemSelNameIsPathSoFar154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; ip::req_t req_dly [2]; endinterface
module m(tif bus, input logic clk, input logic [7:0] x);
  always_ff @(posedge clk) bus.req_dly[1].adr <= x;
endmodule
module top(input logic clk, input logic [7:0] x); tif b(); m u(b, clk, x); endmodule
