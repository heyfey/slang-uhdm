package p;
  function automatic logic [07:0] f(logic [07:00] x);
    return x;
  endfunction
endpackage
module top (input logic [7:0] i, output logic [7:0] o);
  assign o = p::f(i);
endmodule
