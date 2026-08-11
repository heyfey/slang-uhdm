// r10uvm46 arm t63c — CELL (TWO elaborated copies of the bind target under ONE
// parent).  `bindAllInstances_` runs per ELABORATED INSTANCE, so each copy gets
// its own bind instance; both copies share the SAME parent, so if the twin is
// published into the target's parent this parent must list add_sub_if0 TWICE
// under the same VpiName.  That is the cell that says whether the twin is
// per-COPY or per-BIND-DIRECTIVE.
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

module t63c;
  bit clk;
  wire [8:0] r1, r2;
  ADD_SUB dut1(.clk(clk), .a0(8'h2), .b0(8'h3), .doAdd0(1'b1), .result0(r1));
  ADD_SUB dut2(.clk(clk), .a0(8'h4), .b0(8'h5), .doAdd0(1'b0), .result0(r2));
endmodule
