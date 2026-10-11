// § escBlockNameSpanTrailSpace286
module top;
  logic a;
  if (1) begin : g
    always_comb begin : \p.q 
      a = 1'b1;
    end
  end
endmodule
