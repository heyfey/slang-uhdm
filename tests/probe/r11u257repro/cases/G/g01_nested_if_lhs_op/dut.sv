// § defGenLhsSelIdxThroughBase257 (Earlgrey_0_1 #214166: a genvar index operation on a continuous-assignment target inside nested generate ifs)
module m #(parameter int N = 2, parameter bit D = 1)(input logic [7:0] x, output logic [7:0] y);
  logic [7:0] st [N+1];
  assign st[0] = x;
  for (genvar k = 0; k < N; k++) begin : gen_round
    if (D) begin : gen_dec
      if (N == 2) begin : gen_d64
        assign st[k+1] = st[k] ^ 8'h1;
      end else begin : gen_d32
        assign st[k+1] = st[k];
      end
    end else begin : gen_enc
      assign st[k+1] = ~st[k];
    end
  end
  assign y = st[N];
endmodule
module top; logic [7:0] x, y; m u(.x(x), .y(y)); endmodule
