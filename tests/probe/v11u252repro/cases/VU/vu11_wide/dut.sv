// § dupImportSameValueKeeps252
package p;
parameter logic [99:0] WD = 100'h1_0000_0000_0000_0001;
parameter logic [63:0] Q = 64'hdead_beef_0000_0001;
parameter X = 'x;
endpackage
import p::*;
module top(output logic [7:0] o);
  assign o = WD[7:0] ^ Q[7:0];
endmodule
