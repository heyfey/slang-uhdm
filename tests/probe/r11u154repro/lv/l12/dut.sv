// § lvPathSelNamedByChain154
package ip; typedef struct packed { logic [7:0] adr; } req_t; endpackage
interface tif; logic [7:0] wdtxx; ip::req_t rqq; endinterface
module m(tif bs, input logic clk, input logic [1:0] x, input logic [2:0] k);
  always_ff @(posedge clk) bs.rqq.adr[k +: 2] <= x;
endmodule
module top(input logic clk, input logic [1:0] x, input logic [2:0] k); tif b(); m u(b, clk, x, k); endmodule
