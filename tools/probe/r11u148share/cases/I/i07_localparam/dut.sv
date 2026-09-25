package p;
   localparam int W = 16;
   function automatic logic [W-1:0] inc(logic [W-1:0] x);
      return x + 1;
   endfunction
endpackage
module top import p::*; (input logic [15:0] a, output logic [15:0] o);
   assign o = inc(a);
endmodule
