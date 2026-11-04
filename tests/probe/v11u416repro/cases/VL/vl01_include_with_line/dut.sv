// § lineDirectiveIgnored416
module top();
  logic a;
  `include "inc.svh"
  assign a = b;
endmodule
