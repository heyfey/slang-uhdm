// § impUnbasedReadIsLit405
package p;
  localparam b_lp = '1;
endpackage
module top import p::*; (input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(logic [3:0] x); return x & b_lp; endfunction
  assign o = f(i);
endmodule
