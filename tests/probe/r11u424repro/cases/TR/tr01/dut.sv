// residue (no law landed): a module typedef or parameter range bound holding a system call kept unfolded in golden, see README
module top #(parameter W = 4, parameter N = 2) (input logic [W-1:0] a);
  typedef logic [W-1:0] t;
  t x;
endmodule
