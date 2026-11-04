// § addOperandConstMint475
// a child two levels down reading an imported add
package a;
  parameter logic [5:0] PA = 6'd33;
  parameter logic [5:0] PC = PA + 1;
endpackage
module leaf(output logic [5:0] y);
  import a::*;
  assign y = PC;
endmodule
module mid(output logic [5:0] y);
  leaf l(y);
endmodule
module top(output logic [5:0] y);
  mid m(y);
endmodule
