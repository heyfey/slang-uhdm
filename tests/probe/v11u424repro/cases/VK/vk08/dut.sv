// § boundSizedLitKept424
module top;
  if (1) begin : g
    logic [4'd7:0] x;
  end
  typedef enum logic [2'd1:0] {A, B} e_t;
  e_t e;
endmodule
