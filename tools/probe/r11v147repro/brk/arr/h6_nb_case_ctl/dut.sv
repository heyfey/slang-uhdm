// § nonblockingSelLhsBindsWholeRef151
module top(input logic clk, input logic [1:0] s, input logic a, output logic [3:0] y);
  logic [3:0] v;
  always_ff @(posedge clk) begin
    case (s)
      2'd0: v[0] <= a;
      default: v[1] <= a;
    endcase
    y <= v;
  end
endmodule
