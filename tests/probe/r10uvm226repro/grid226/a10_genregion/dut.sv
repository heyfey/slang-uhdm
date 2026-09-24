// arm a10: an explicit `generate ... endgenerate` REGION inside an interface.
// collectInterfaceObjects_ pushes paGenerate_region onto its stopPoints for
// every collectType except GENERATE_REGIONS-with-an-instance, exactly as
// collectModuleObjects_ does — so DesignElaboration re-enters CompileModule
// once per INSTANCE and appends a FRESH process to the DEFINITION each time.
// The module road already models that (`regionPbs` x defAllInstCount); this arm
// asks whether the interface road answers the same way.
interface if226_gr();
   logic clk226;
   logic a226, b226;

   initial begin a226 = 1'b0; end      // the interface's OWN process

   generate
      initial begin b226 = 1'b0; end   // a REGION process
      always @(posedge clk226) begin b226 <= ~b226; end
   endgenerate
endinterface

// UNINSTANTIATED twin: no instance, so the region contributes zero repetitions.
interface if226_gru();
   logic clk226;
   logic a226, b226;
   initial begin a226 = 1'b0; end
   generate
      initial begin b226 = 1'b0; end
   endgenerate
endinterface

module top226_gr;
   if226_gr u_a226();
   if226_gr u_b226();
endmodule
