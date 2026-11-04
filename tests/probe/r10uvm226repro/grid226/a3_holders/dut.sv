// arm a3: THE HOLDER FENCE.  The identical six processes under every holder
// this law could reach.  The MODULE road's def-view process emission is the
// fence's FIRST FACE: it already lists them and MUST NOT MOVE.
module mod226_h;                       // uninstantiated module definition
   logic clk226;
   logic a226, b226, c226, d226, e226;
   initial begin a226 = 1'b0; end
   always @(clk226) begin b226 = ~b226; end
   always_comb begin c226 = a226 & b226; end
   always_ff @(posedge clk226) begin d226 <= a226; end
   always_latch begin if (clk226) e226 = a226; end
   final begin $display("a3 mod final"); end
endmodule

module mod226_hi;                      // INSTANTIATED module definition
   logic clk226;
   logic a226;
   initial begin a226 = 1'b0; end
   always @(clk226) begin a226 = ~a226; end
endmodule

program prg226_h;                      // uninstantiated program definition
   logic a226;
   initial begin a226 = 1'b0; end
   final begin $display("a3 prg final"); end
endprogram

// A CHECKER is the fourth process holder Surelog knows.
checker chk226_h(logic clk226);
   logic a226;
   always_comb begin a226 = clk226; end
endchecker

module top226_h;
   mod226_hi u_m226();
endmodule
