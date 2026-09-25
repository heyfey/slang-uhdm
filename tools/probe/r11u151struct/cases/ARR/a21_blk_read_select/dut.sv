// ARR: a19's shape with BLOCKING assignments (the net model's own ground, not
// this pass's): a select write in one begin, a whole write reading a select
// of the same name in a sibling begin.
module top(input logic c, input logic [1:0] x, input logic [5:0] i, output logic [5:0] y);
  logic [5:0] r;
  always_comb begin
    r = i;
    if (c) begin
      r[3:2] = r[3:2] + 2'd1;
    end else begin
      r = {x, r[3:2], 2'd0};
    end
    y = r;
  end
endmodule
