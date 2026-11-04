// § pkgTfSigRangeTopViewConst148
package p;
   parameter int W = 16;
   task automatic t(input logic [W-1:0] x, output logic [W-1:0] y);
      y = x;
   endtask
endpackage
module top import p::*; (output logic o);
   assign o = 1'b0;
endmodule
