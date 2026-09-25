package p;
  localparam int W = 12;
  typedef logic signed [W-1:0] v_t;
  function automatic v_t f(logic [11:0] x);
    return v_t'(x);
  endfunction
endpackage
module top(input logic [11:0] i, output logic [11:0] o);
  assign o = p::f(i);
endmodule
