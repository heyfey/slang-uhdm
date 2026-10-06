// § defGenLhsSelIdxThroughBase257 (a concatenation target (the select not a direct child))
module m #(parameter int N = 2)(input logic [7:0] x, output logic [7:0] y);
  logic [7:0] st [N+2]; logic [7:0] w [N+2]; logic [3:0] ix [4]; 
  assign st[0] = x; assign w[0] = x; assign ix[0] = '0; assign ix[1] = 4'd1; assign ix[2] = 4'd2; assign ix[3] = 4'd3;
  for (genvar k = 0; k < N; k++) begin : gen_round
    assign {st[k+1], w[k+1]} = st[k] ^ 8'h1;
  end
  assign y = st[N];
endmodule
module top; logic [7:0] x, y; m u(.x(x), .y(y)); endmodule
