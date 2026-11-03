// § caReduceLeavesOpKept475
// qualified and imported package parameters under ^ and unary plus
package p;
  parameter logic [5:0] PA = 6'd33;
  parameter logic [5:0] PB = 6'h05;
endpackage
module top(output logic [5:0] y, output logic [5:0] z, output logic q);
  assign y = p::PA ^ p::PB;
  assign z = +p::PA;
  assign q = p::PA ==? 6'b1000x1;
endmodule
