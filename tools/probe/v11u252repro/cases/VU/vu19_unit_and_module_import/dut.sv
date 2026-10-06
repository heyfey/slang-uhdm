// § dupImportSameValueKeeps252
package p;
parameter int A = 3;
parameter int B = A * 4;
endpackage
import p::*;
module top import p::*; ();
endmodule
