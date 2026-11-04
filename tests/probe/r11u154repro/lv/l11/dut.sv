// § lvPathSelNamedByChain154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; logic [7:0] wdtxx; ip::req_t rqq; endinterface
module m(tif bs, input logic clk, input logic [3:0] x);
  always_ff @(posedge clk) bs.rqq.adr[3:0] <= x;
endmodule
module top(input logic clk, input logic [3:0] x); tif b(); m u(b, clk, x); endmodule
