// r10uvm46 arm t63d — THE DISCRIMINATOR CELL (target nested TWO levels down).
// SimpleUVM cannot tell "the twin goes to the target's PARENT" from "the twin
// goes to the design TOP", because there the target's parent IS the top.  Here
// the target sits at t63d.mid.dut, so the two candidate laws predict DIFFERENT
// holders: mid (parent) vs t63d (top).
module ADD_SUB(
  input            clk,
  input [7:0]      a0,
  input [7:0]      b0,
  input            doAdd0,
  output reg [8:0] result0
);
  always @ (posedge clk)
    begin
      if (doAdd0)
        result0 <= a0 + b0;
      else
        result0 <= a0 - b0;
    end
endmodule: ADD_SUB

interface add_sub_if(
  input bit clk,
  input [7:0] a,
  input [7:0] b,
  input       doAdd,
  input [8:0] result
);
  clocking cb @(posedge clk);
    output    a;
    output    b;
    output    doAdd;
    input     result;
  endclocking
endinterface: add_sub_if

bind ADD_SUB add_sub_if add_sub_if0(
  .clk(clk),
  .a(a0),
  .b(b0),
  .doAdd(doAdd0),
  .result(result0)
);

module mid63(input bit clk, output wire [8:0] r);
  ADD_SUB dut(.clk(clk), .a0(8'h2), .b0(8'h3), .doAdd0(1'b1), .result0(r));
endmodule

module t63d;
  bit clk;
  wire [8:0] r;
  mid63 mid(.clk(clk), .r(r));
endmodule
