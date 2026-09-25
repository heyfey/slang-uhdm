package p;
   parameter int W = 8;
   function automatic logic [W-1:0] ones();
      return '1;
   endfunction
endpackage
module top import p::*; (output logic [7:0] o);
   assign o = ones();
endmodule
