package p;
  typedef logic [16-1:0] h_t;
  task automatic t(input logic [7:0] x, output h_t y);
    y = h_t'(x);
  endtask
endpackage
module top(input logic [7:0] i, output logic [15:0] o);
  always_comb p::t(i, o);
endmodule
