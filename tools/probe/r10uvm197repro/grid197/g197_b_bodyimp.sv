package strPkg;
  parameter string S_MGC = "hello world";
  parameter        U_STR = "untyped";
endpackage
module bodyTop;
  import strPkg::*;
  initial $display(S_MGC);
endmodule
