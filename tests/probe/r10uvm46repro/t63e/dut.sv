// r10uvm46 arm t63e — THE OVERWRITE/GC CELL, and the reason a "just publish the
// twin" implementation could be WRONG in half the cases.
//
// `UhdmWriter::writeInstance` attaches `netlist->interfaces()` (where the twin
// lives) to the holder, and THEN its child-instance walk builds a FRESH
// interface vector for the holder's own interface instantiations and OVERWRITES
// the field with it (the netlist branch declares its own shadowing local, so the
// outer `subInterfaces` is still null at the child walk).  So a holder that
// ALSO instantiates an interface directly should keep ONLY its own child, and
// the twin — now unreachable — should be dropped by Serializer::GarbageCollect.
// Here t63e instantiates `add_sub_if own_if` itself AND the bind target.
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

module t63e;
  bit clk;
  wire [8:0] r;
  add_sub_if own_if(.clk(clk), .a(8'h1), .b(8'h1), .doAdd(1'b1), .result(r));
  ADD_SUB dut(.clk(clk), .a0(8'h2), .b0(8'h3), .doAdd0(1'b1), .result0(r));
endmodule
