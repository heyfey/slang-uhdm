// § ifaceDefListsItsOwnProcesses226 — arm a1: THE KIND GRID, in an
// UNINSTANTIATED interface.  Every process kind SystemVerilog allows as an
// interface item, one of each, in written order.  A top module is present so
// the design has one (r10uvm225's R5: a ported interface alone in a file
// segfaults the pristine binary) but it does NOT instantiate the interface.
interface if226_k();
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
      $display("a1 final");
   end
endinterface

module top226_k;
   logic unused226;
endmodule
