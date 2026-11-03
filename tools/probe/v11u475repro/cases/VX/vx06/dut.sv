// § caReduceLeavesOpKept475
// a genvar operand in a generate loop
module top(output logic [3:0] y);
  parameter int P = 1;
  for (genvar i = 0; i < 4; i++) begin : g
    assign y[i] = i ^ P;
  end
endmodule
