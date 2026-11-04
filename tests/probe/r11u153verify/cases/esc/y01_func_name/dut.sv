// § escIdPpColumnShift146
module top(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] \f$x (logic [3:0] a); return a; endfunction
  assign o = \f$x (i) ^ i;
endmodule
