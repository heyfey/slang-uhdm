// arm a4: GENERATE SCOPES inside an interface.  collectInterfaceObjects_ puts
// paGenerate_region, the conditional and the loop constructs on its stopPoints
// list exactly as collectModuleObjects_ does, so a process written inside one
// must NOT reach the interface's own Process() list from the DEFINITION pass.
interface if226_g();
   logic clk226;
   logic a226, b226, c226;

   initial begin a226 = 1'b0; end          // the interface's OWN process

   if (1) begin : g_if226                  // conditional generate
      initial begin b226 = 1'b0; end
   end

   for (genvar gi226 = 0; gi226 < 2; gi226++) begin : g_lp226   // loop generate
      initial begin c226 = 1'b0; end
   end
endinterface

// The same shape INSTANTIATED, so the elab view can be read beside it.
interface if226_gi();
   logic clk226;
   logic a226, b226;
   initial begin a226 = 1'b0; end
   if (1) begin : g_if226i
      initial begin b226 = 1'b0; end
   end
endinterface

module top226_g;
   if226_gi u_gi226();
endmodule
