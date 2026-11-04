// § clsScopedBoundWholeSpan201
class K;
  localparam int unsigned V = 6;
  localparam int unsigned W = 1;
endclass
module top (input logic [31:0] x, output logic [31:0] y1);
  function automatic logic [31:0] f(input logic [31:0] a);
    return a[K::V:0];
  endfunction
  assign y1 = f(x);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [31:0] z;
    assign z = x[K::V:i];
  end
endmodule
