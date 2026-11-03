// § caReduceLeavesOpKept475
// system-call and localparam operands
module top(output logic [3:0] y, output logic [7:0] z);
  parameter int P = 16;
  localparam int L = P * 2;
  assign y = $clog2(P) ^ 4'd1;
  assign z = L ^ P;
endmodule
