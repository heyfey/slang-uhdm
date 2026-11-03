// § caReduceLeavesOpKept475
// operands wider than 64 bits
module top(output logic [95:0] y);
  parameter logic [95:0] W = 96'h123456789abcdef012345678;
  assign y = W ^ 96'h1;
endmodule
