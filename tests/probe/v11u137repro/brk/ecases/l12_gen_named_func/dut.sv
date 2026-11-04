// § elabCloneFullNameUnstored137
module dut #(parameter int N = 2)(input logic [N-1:0] a, output logic [N-1:0] b);
  for (genvar i = 0; i < N; i++) begin : g
    logic t;
    always_comb begin : blk
      t = a[i];
    end
    assign b[i] = t;
  end
endmodule
module top(input logic [1:0] x, output logic [1:0] y);
  dut u(.a(x), .b(y));
endmodule
