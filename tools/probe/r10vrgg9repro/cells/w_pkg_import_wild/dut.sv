package pk;
  parameter bit PP = 1;
endpackage
module m;
  import pk::*;
  logic [7:0] arr[2];
  assign arr[0] = (PP) ? 42 : 7;
endmodule
module top;
  m u_a();
endmodule
