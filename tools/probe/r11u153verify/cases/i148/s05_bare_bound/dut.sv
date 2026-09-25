// § pkgTfSigRangeTopViewConst148
package p;
   parameter int W = 7;
   function automatic logic [W:0] inc(logic [W:0] x);
      return x + 1;
   endfunction
endpackage
module top import p::*; (input logic [7:0] a, output logic [7:0] o);
   assign o = inc(a);
endmodule
