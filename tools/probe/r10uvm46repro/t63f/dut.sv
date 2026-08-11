// r10uvm46 arm t63f — THE CONTENT CELL.  t63a says the twin holds the SAME port
// and variable OBJECTS as the instance it twins (pointer identity, `-p`) but
// NONE of its nets and NONE of its clocking blocks.  A single interface shape
// cannot tell "ports+variables" from "everything that is not a net", so this
// interface carries one of everything: net ports and variable ports, an internal
// VARIABLE, an internal WIRE, a modport, a task and a function, a parameter, a
// continuous assignment and an always block.  Whatever the twin ends up holding
// here IS the rule, and cmp compares every one of those vectors.
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
  parameter int WIDTH = 8;
  int          cnt;
  wire         w_int;
  logic [3:0]  v_int;
  assign w_int = doAdd;
  always @(posedge clk) cnt <= cnt + 1;
  clocking cb @(posedge clk);
    output    a;
    output    b;
    output    doAdd;
    input     result;
  endclocking
  modport mp (input a, input b, output doAdd);
  function automatic int getcnt(); return cnt; endfunction
  task automatic bump(); cnt = cnt + 1; endtask
endinterface: add_sub_if

bind ADD_SUB add_sub_if add_sub_if0(
  .clk(clk),
  .a(a0),
  .b(b0),
  .doAdd(doAdd0),
  .result(result0)
);

module t63f;
  bit clk;
  wire [8:0] r;
  ADD_SUB dut(.clk(clk), .a0(8'h2), .b0(8'h3), .doAdd0(1'b1), .result0(r));
endmodule
