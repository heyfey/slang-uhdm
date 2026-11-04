// § pkgTfSigRangeTopViewConst148
package p;
   parameter int W = 8;
   parameter int V = 4;
   function automatic logic [W-1:0] f(logic [W-1:0] a, logic [V-1:0] b);
      return a + b;
   endfunction
endpackage
module top(input logic [7:0] a, output logic [7:0] o);
   assign o = p::f(a, 4'd1);
endmodule
