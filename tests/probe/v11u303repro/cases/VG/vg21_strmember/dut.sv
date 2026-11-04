// § genNdaSelRhsSharesNet303
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module top (input s_t sv, output logic o);
  for (genvar i = 0; i < 2; ++i) begin : g
    wire [3:0] w = sv.a;
    wire [1:0] x = sv.b[1:0];
  end
  assign o = 1'b0;
endmodule
