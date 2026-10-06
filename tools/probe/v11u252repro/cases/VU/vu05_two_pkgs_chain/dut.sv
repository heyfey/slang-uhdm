// § dupImportSameValueKeeps252
package p;
parameter A = 2;
endpackage
package q;
import p::*;
parameter QB = A + 10;
endpackage
package r;
parameter RC = 'h1f;
endpackage
import q::*;
import r::*;
module top(output logic [7:0] o);
  assign o = QB + RC;
endmodule
