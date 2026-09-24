// v201 arm H — the reference-defaulted copy in an INTERFACE and a PROGRAM
// def listing, and in a module with a BODY import (one copy) beside the
// file-scope one (two).
package p201vh;
  parameter H_A = 13;
  parameter H_B = H_A;
endpackage
import p201vh::*;
interface i201vh;
endinterface
program pr201vh;
endprogram
module m201vh;
  import p201vh::*;
endmodule
