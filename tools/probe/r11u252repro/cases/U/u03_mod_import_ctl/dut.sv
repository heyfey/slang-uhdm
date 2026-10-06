// § dupImportSameValueKeeps252
package p;
parameter A = (1<<3);
parameter C = A+1;
endpackage
module top; import p::*; int x = A; endmodule
