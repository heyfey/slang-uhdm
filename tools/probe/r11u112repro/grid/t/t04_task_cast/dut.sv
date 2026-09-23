module top(input logic [7:0] a, output logic [7:0] y);
  typedef logic [7:0] t;
  task automatic tk(output t o, input logic [7:0] x); o = t'(x); endtask
  always_comb tk(y, a);
endmodule
