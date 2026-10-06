// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
interface ifc import hp::*; ();
  logic [$clog2(NumRound)-1:0] r;
  modport mp (input r);
endinterface
module sha2 (ifc.mp p);
endmodule
module top;
  ifc i ();
  sha2 u (.p(i));
endmodule
