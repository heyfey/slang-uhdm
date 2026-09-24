// r10uvm210 grid arm B — the CORPUS CHAIN at 1/1000 the size.  uvm-1.2
// uvm_object_globals.svh:175-221: a literal, a shift over it, three `+1` hops
// and then the BARE REFERENCE (`UVM_SETINT = UVM_SET`) that is this pass's
// briefed head, next to a second bare reference whose referent is a LITERAL.
package p210b;
  parameter B_NUMFLAGS   = 17;
  parameter B_EXTRAS     = (1<<B_NUMFLAGS);
  parameter B_END_DATA   = B_EXTRAS+4;
  parameter B_START      = B_END_DATA+1;
  parameter B_SET        = B_START+1;
  parameter B_SETINT     = B_SET;        // <- the head's shape
  parameter B_SETSTR     = B_START+3;
  parameter B_END_FUNCS  = B_SETSTR;     // <- the same shape again
  parameter B_LIT        = 5;
  parameter B_REFLIT     = B_LIT;        // <- referent is a folded literal
endpackage
module m210b;
endmodule
