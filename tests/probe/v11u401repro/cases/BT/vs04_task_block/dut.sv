// § bitsBlockLocalKeepsCall401
module top;
  int n;
  task t; begin : blk logic [6:0] v; n = $bits(v); end endtask
  initial t();
endmodule
