// § operatorAttrsListed403
module top;
  parameter int P = 3 + (* m = "x" *) 4;
  int y = P;
endmodule
