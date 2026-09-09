// arm a2: the SAME six kinds in an INSTANTIATED interface — the DEF view and
// the ELAB view of one interface, so the law can be read on both.
interface if226_i();
   logic clk226;
   logic a226, b226, c226, d226, e226;

   initial begin
      a226 = 1'b0;
   end

   always @(clk226) begin
      b226 = ~b226;
   end

   always_comb begin
      c226 = a226 & b226;
   end

   always_ff @(posedge clk226) begin
      d226 <= a226;
   end

   always_latch begin
      if (clk226) e226 = a226;
   end

   final begin
      $display("a2 final");
   end
endinterface

module top226_i;
   if226_i u_i226();
endmodule
