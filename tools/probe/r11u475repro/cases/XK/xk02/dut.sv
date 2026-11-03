// § caReduceLeavesOpKept475
package a;
  parameter logic [5:0] PA = 6'd33;
  parameter logic [5:0] PB = 6'd5;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  assign y = PA ^ PB;
  assign z = (PA ^ PB) + 6'd1;
endmodule
