// § genLocalEnumConstShared184 § enumConstUnderscoreDropped186: a generate-block enum whose values are written with separators, read in the block's process and a nested block's process
module top (input logic clk, output int y);
  if (1) begin : g
    typedef enum int {A = 1_0, B = 2_000, C = 3_000_000} e_t;
    e_t st;
    always_ff @(posedge clk) st <= (st == A) ? B : (st == B) ? C : A;
    if (1) begin : h
      always_comb y = (st == C) ? 1_0 : 0;
    end
  end
endmodule
