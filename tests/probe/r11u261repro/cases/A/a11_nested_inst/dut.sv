// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module leaf import hp::*; ();
  logic [$clog2(NumRound)-1:0] round;
endmodule
module mid; leaf l (); endmodule
module top;
  mid m1 (); mid m2 ();
endmodule
