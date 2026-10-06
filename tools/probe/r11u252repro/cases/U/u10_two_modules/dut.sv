// § dupImportSameValueKeeps252
package p;
parameter A = (1<<3);
parameter C = A+1;
endpackage
import p::*;
module sub #(parameter W = A); endmodule
module top; sub u(); sub #(.W(C)) v(); endmodule
