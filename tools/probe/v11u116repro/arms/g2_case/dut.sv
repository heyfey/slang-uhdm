package p;
  parameter int unsigned P = 32;
endpackage
module dut import p::*; ();
  logic clk;
  logic [127:0] q [4];
  logic [127:0] d [4];
  logic [63:0] v [4];
  for (genvar f = 0; f < 2; f++) begin : gf
    for (genvar b = 0; b < 2; b++) begin : gb
      always_ff @(posedge clk) begin
        case (d[f][1:0])
          2'd0: v[f][P] <= 1'b1;
          default: v[f][P+1] <= 1'b0;
        endcase
      end
    end
  end
endmodule
