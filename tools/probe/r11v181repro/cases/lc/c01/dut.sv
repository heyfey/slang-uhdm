// § procLvIdxCallWholeSpan181 (v11u181 break: call index lvalues in an interface always, a program initial, a final block, a generate-scope always, a function in a generate scope)
interface ifc(input logic clk);
  logic [7:0] r;
  function automatic int ix(int a); return a & 7; endfunction
  always @(posedge clk) r[ix(3)] <= 1'b1;
endinterface
program prg;
  logic [7:0] q;
  function automatic int ix(int a); return a; endfunction
  initial q[ix(2)] = 1'b1;
endprogram
module top(input logic clk);
  logic [7:0] a;
  function automatic int f(int x); return x + 1; endfunction
  final a[f(0)] = 1'b0;
  for (genvar g = 0; g < 2; g++) begin : G
    logic [7:0] b;
    function automatic int h(int x); b[f(x)] = 1'b1; return x; endfunction
    always @(posedge clk) b[f(g)] <= 1'b0;
  end
  ifc u(.clk(clk));
  prg p();
endmodule
