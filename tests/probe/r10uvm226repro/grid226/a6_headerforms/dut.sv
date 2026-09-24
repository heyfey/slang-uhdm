// arm a6: the HEADER FORM axis.  r10uvm224's typespec law IS gated on the
// header form and r10uvm225's array_net law is NOT; this arm asks which of the
// two the process law resembles.  Four spellings, all uninstantiated.
interface if226_ep();            // EMPTY parens
   logic a226;
   initial begin a226 = 1'b0; end
endinterface

interface if226_np;              // NO parens
   logic a226;
   initial begin a226 = 1'b0; end
endinterface

interface if226_ansi(input logic clk226, output logic q226);   // ANSI ports
   logic a226;
   initial begin a226 = 1'b0; end
   always @(posedge clk226) begin q226 <= a226; end
endinterface

interface if226_na(clk226, q226);          // genuine NON-ANSI
   input clk226;
   output q226;
   logic clk226;
   logic q226;
   logic a226;
   initial begin a226 = 1'b0; end
   always @(posedge clk226) begin q226 <= a226; end
endinterface

module top226_hdr;
   logic unused226;
endmodule
