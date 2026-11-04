// § escBlockNameSpanTrailSpace286
module top;
  logic a;
  always_comb begin : \a/very/long/escaped[name]_with.dots 
    a = 1'b0;
  end
endmodule
