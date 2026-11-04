// § ifcTaskFixupWalksWait456
interface bfm(input logic clk);
  logic [7:0] data;
  logic [3:0] idx;
  logic [7:0] mem [16];
  function automatic logic [7:0] rd();
    logic [7:0] r;
    r = mem[idx];
    r = r ^ data[idx[1:0]];
    r = r | mem[idx][3 +: 2];
    return r;
  endfunction
endinterface
module top;
  logic clk;
  logic [7:0] y;
  bfm u(.clk(clk));
  initial y = u.rd();
endmodule
