// r10uvm46 arm t63b — CELL (target NOT instantiated, so it is itself a TOP).
// InterfaceBinding's cell, plus a SECOND unrelated top, to check that "the
// target is a top-level instance" (parent == nullptr in
// createBindInstance_, which then re-parents the bind instance onto the TARGET
// itself) is what collapses the two publications into one — and not simply
// "there is only one top in the design".
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

module t63b;
  bit unrelated;
endmodule
