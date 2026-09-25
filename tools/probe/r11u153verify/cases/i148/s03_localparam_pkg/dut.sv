// § pkgTfSigRangeTopViewConst148
package p;
   localparam int W = 12;
   function automatic logic [W-1:0] inc(logic [W-1:0] x);
      return x + 1;
   endfunction
endpackage
module top import p::*; (input logic [11:0] a, output logic [11:0] o);
   assign o = inc(a);
endmodule
