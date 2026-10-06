// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
interface ifc import hp::*; ();
  logic [$clog2(NumRound)-1:0] round;
endinterface
module top;
  ifc i ();
endmodule
