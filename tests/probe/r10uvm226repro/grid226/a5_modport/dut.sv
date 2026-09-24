// arm a5: a MODPORT interface with processes — the InterfaceModPort canary's
// own shape.  InterfaceModPort MUST NOT MOVE, so this arm exists to prove the
// modport objects are untouched by a process list appearing beside them.
interface if226_mp(input logic clk226);
   logic a226, b226;

   initial begin a226 = 1'b0; end
   always @(posedge clk226) begin b226 <= a226; end

   modport mp226_src (output a226, input b226, input clk226);
   modport mp226_snk (input a226, output b226, input clk226);
endinterface

// UNINSTANTIATED twin (no port, so the R5 crash shape is avoided).
interface if226_mpu();
   logic clk226;
   logic a226, b226;
   initial begin a226 = 1'b0; end
   always @(posedge clk226) begin b226 <= a226; end
   modport mp226u_src (output a226, input b226);
   modport mp226u_snk (input a226, output b226);
endinterface

module top226_mp;
   logic clk226;
   if226_mp u_mp226(.clk226(clk226));
endmodule
