// § foldedBoundTsRefUnstored144
module top(input logic clk, output int o);
   localparam int D = 4;
   logic [D-1:0] a, b;
   logic [2*D:D] c;
   always_ff @(posedge clk) begin
     a <= a + 1;
     b <= a;
     c <= {a, 1'b0};
   end
   assign o = int'(b) + int'(c);
endmodule
