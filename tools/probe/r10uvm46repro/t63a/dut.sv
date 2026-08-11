// r10uvm46 arm t63a — CELL (target INSTANTIATED once, ONE elaborated copy).
// The SimpleUVM shape with the UVM removed: the bind TARGET is instantiated as
// a child of the top, so the target instance HAS a parent.  Prediction from the
// Surelog read (DesignElaboration::createBindInstance_ parents the bind instance
// at `parent->getParent()`, NetlistElaboration::elaborate_ then self-registers
// an interface-type instance into ITS PARENT's netlist->interfaces()): the bind
// interface appears TWICE — once under the TARGET (UhdmWriter's child walk) and
// once under the target's PARENT (the netlist twin).
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

module t63a;
  bit clk;
  wire [8:0] r;
  ADD_SUB dut(.clk(clk), .a0(8'h2), .b0(8'h3), .doAdd0(1'b1), .result0(r));
endmodule
