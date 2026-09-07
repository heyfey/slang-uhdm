// SCOPE KINDS and IMPORT SPELLINGS under one file-scope import:
// an INTERFACE, a PROGRAM, an EXPLICIT file-scope import, and a re-exporting
// package (masonPkg carries quarryPkg's four parameters plus its own).
import masonPkg::*;
module eMod;
  int r;
  initial r = masonTake(1);
endmodule
interface eIf;
  int r;
endinterface
program eProg;
  int r;
  initial r = masonTake(2);
endprogram
