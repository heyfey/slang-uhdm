// § elabCloneInstTreeUnstored144
module carryadd(a, b, y);
parameter WIDTH = 2;
input [WIDTH-1:0] a, b;
output [WIDTH-1:0] y;
genvar i;
generate
  for (i = 0; i < WIDTH; i = i+1) begin:STAGE
    wire IN1 = a[i], IN2 = b[i];
    wire C;
    if (i == 0)
      assign C = IN1 & IN2;
    else
      assign C = IN1 & STAGE[i-1].C;
    assign y[i] = C;
  end
endgenerate
endmodule
