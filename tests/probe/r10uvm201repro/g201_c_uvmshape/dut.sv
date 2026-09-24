// r10uvm201 grid arm C — the CORPUS SHAPE at 1/1000 the size:
// uvm_object_globals.svh's UVM_MACRO_EXTRAS -> UVM_START_FUNCS -> UVM_SET ->
// UVM_SETINT chain, next to a `parameter int` and a `parameter string` that
// must KEEP theirs.
package p201c;
  parameter C_MACRO_NUMFLAGS  = 17;
  parameter C_MACRO_EXTRAS    = (1<<C_MACRO_NUMFLAGS);
  parameter C_END_DATA_EXTRA  = C_MACRO_EXTRAS+4;
  parameter C_START_FUNCS     = C_END_DATA_EXTRA+1;
  parameter C_SET             = C_START_FUNCS+1;
  parameter C_SETINT          = C_SET;
  parameter C_SETSTR          = C_START_FUNCS+3;
  parameter C_END_FUNCS       = C_SETSTR;
  parameter int    C_KEEP_INT = 5;
  parameter string C_KEEP_STR = "keep";
endpackage
import p201c::*;
module m201c;
endmodule
