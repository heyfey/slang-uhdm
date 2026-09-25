// § pselConnNameNotFrozen155 § lvPathSelNamedByChain154 § lvPathBaseAtFirstMember154
interface tif; logic [7:0] wdtxx; endinterface
module m(tif bs, input logic clk, input logic [3:0] x);
  always_ff @(posedge clk) bs.wdtxx[3:0] <= x;
endmodule
module top(input logic clk, input logic [7:0] in_i);
  tif b();
  if (1) begin : gen_inst
    m u(.bs(b), .clk(clk), .x(in_i[5:2]));
  end
endmodule
