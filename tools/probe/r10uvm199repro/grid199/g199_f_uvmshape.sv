// r10uvm199 grid arm F — the CORPUS SHAPE at 1/1000 the size: the four
// `uvm_object_globals.svh` declarations that ARE the head, written verbatim
// (`UVM_RADIX = 'hf000000`, and the three `'b…` flag masks), file-scope
// imported into a module.  Alongside them two parameters that MUST KEEP their
// typespec, so a blind widening is convicted here.
package fPkg;
  parameter F_RADIX     = 'hf000000;
  parameter F_DEFAULT   = 'b000010101010101;
  parameter F_ALL_ON    = 'b000000101010101;
  parameter F_FLAGS_ON  = 'b000000101010101;
  parameter int    F_KEEP_INT = 9;
  parameter string F_KEEP_STR = "keep";
endpackage
import fPkg::*;
module fTop;
  initial $display(F_RADIX);
endmodule
