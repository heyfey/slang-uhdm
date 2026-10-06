// § defGenLhsSelIdxThroughBase257 (control: a genvar index operation on the right side)
module m #(parameter int N = 2)(input logic [7:0] x, output logic [7:0] y [N]);
  logic [7:0] st [N+1];
  assign st[0] = x;
  assign st[1] = x;
  assign st[2] = x;
  for (genvar k = 0; k < N; k++) begin : gen_round
    if (1) begin : gen_a
      assign y[k] = st[k+1];
    end
  end
endmodule
module top; logic [7:0] x; logic [7:0] y [2]; m u(.x(x), .y(y)); endmodule
