// § bitsBlockLocalKeepsCall401
module top;
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  int n;
  initial begin s_t v; n = $bits(v); end
endmodule
