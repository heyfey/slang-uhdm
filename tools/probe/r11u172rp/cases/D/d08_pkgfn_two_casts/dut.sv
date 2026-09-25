package p;
  typedef logic signed [16-1:0] h_t;
  typedef logic signed [32-1:0] w_t;
  function automatic w_t f(logic [7:0] x);
    f = w_t'(h_t'($signed(x)));
  endfunction
endpackage
module top(input logic [7:0] i, output logic [31:0] o);
  assign o = p::f(i);
endmodule
