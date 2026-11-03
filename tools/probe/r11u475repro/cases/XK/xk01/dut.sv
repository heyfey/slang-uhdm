// § caReduceLeavesOpKept475
module top(output logic [5:0] y, output logic [5:0] z, output logic q);
  parameter logic [5:0] PA = 6'd33;
  parameter logic [5:0] PB = 6'd5;
  assign y = PA ^ PB;
  assign z = PA ~^ PB;
  assign q = PA === PB;
endmodule
