// § caReduceLeavesOpKept475
// XOR in a generate block, a reduction-free operator in a parameter (still folds), a signal operand
module top #(parameter int N = 2)(input logic [3:0] i, output logic [3:0] y, output logic [3:0] z, output logic [3:0] w);
  parameter logic [3:0] A = 4'd3;
  parameter logic [3:0] B = 4'd5;
  localparam logic [3:0] C = A ^ B;
  if (N > 1) begin : g
    assign y = A ^ B;
  end
  assign z = C;
  assign w = i ^ A;
endmodule
