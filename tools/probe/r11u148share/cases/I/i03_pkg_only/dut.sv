package p;
   parameter int W = 32;
   function automatic logic [W-1:0] inc(logic [W-1:0] x);
      return x + 1;
   endfunction
endpackage
module top(input logic [31:0] a, output logic [31:0] o);
   assign o = a;
endmodule
