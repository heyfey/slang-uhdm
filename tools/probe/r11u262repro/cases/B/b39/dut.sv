// § genLoopDirectBoundPaConst262 (implicit-net target and a this-free named-block process beside a direct loop bound)
module m #(parameter int Width = 32) (input logic [7:0] a, output logic [5:0] q);
  for (genvar i = 0; i < 2; i++) begin : gf
    assign t = a[Width:1];
    assign q[i*3+:3] = t;
    always_comb begin : nb
      logic [2:0] k;
      k = a[i+:Width];
    end
  end
endmodule
module top(input logic [7:0] a, output logic [5:0] q);
  m #(.Width(3)) u (.*);
endmodule
