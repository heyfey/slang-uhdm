// § lvPathSelNamedByChain154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; logic [7:0] wdt; logic [7:0] rdt; logic write_en; ip::req_t req; ip::req_t req_dly [2]; endinterface
module m(tif bus, input logic clk, input logic [3:0] x);
  localparam int GW = 4;
  always_ff @(posedge clk) bus.wdt[GW-1:0] <= x;
endmodule
module top(input logic clk, input logic [3:0] x); tif b(); m u(b, clk, x); endmodule
