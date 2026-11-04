// ARR: an initial block with a nonblocking bit write and a blocking whole read.
module top(output logic [3:0] y);
  logic [3:0] v;
  initial begin
    v[1] <= 1'b1;
    y = v;
  end
endmodule
