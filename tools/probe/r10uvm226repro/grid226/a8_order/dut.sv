// arm a8: ORDER.  The producer pushes onto ONE vector in the DEFINITION walk's
// visit order, interleaved with nothing else, so the Process() vector must be
// written-declaration order regardless of what sits between the processes.
// The judge compares the vector POSITIONALLY.
interface if226_o();
   logic clk226;
   logic a226, b226, c226;
   int   q226;

   always_comb begin a226 = b226; end        // 1st

   wire w226 = a226;                          // a net between processes

   initial begin b226 = 1'b0; end             // 2nd

   function automatic int f226(); return 1; endfunction

   final begin $display("a8 %0d", q226); end  // 3rd

   assign c226 = a226 | b226;                 // a cont_assign between processes

   always @(posedge clk226) begin q226 <= q226 + 1; end   // 4th

   modport mp226 (input a226, output q226);

   initial begin q226 = 0; end                // 5th
endinterface

module top226_o;
   logic unused226;
endmodule
