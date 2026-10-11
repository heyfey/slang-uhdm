// § escBlockNameSpanTrailSpace286
module top (input clk);
  logic [1:0] a;
  for (genvar i = 0; i < 2; i++) begin : g
    always_ff @(posedge clk) begin : \ff+i 
      a[i] <= 1'b1;
    end
  end
endmodule
