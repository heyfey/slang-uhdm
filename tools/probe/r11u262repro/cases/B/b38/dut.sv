// § genLoopDirectBoundPaConst262 (a class specialization's parameter and a constant function call as select bounds, for and if generate: controls)
class C #(int W = 2);
  localparam int CW = W;
endclass
module m #(parameter int Width = 32, parameter bit E = 0) (input logic [7:0] a, output logic [5:0] q, output logic [2:0] r);
  function automatic int f(int x); return x; endfunction
  for (genvar i = 0; i < 2; i++) begin : gf
    assign q[i*3+:3] = a[i+:C#(3)::CW] ^ a[f(Width):1];
  end
  if (!E) begin : gn
    assign r = a[0+:C#(3)::CW] | a[f(3)-1:0];
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q, output logic [2:0] r);
  m #(.Width(3)) u (.*);
endmodule
