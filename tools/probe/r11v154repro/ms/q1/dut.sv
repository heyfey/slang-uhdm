// § builtinMethodArgNamedByPath154
module top(input logic clk);
   int q[$];
   int x = 3;
   always @(posedge clk) begin
     q.push_front(x);
     q.delete(x);
   end
endmodule
