// § castRhsClonePerInst176
module sub();
  parameter int X = 4;
  parameter logic [X-1:0] Y = '1;
  for (genvar g = 0; g < 2; g++) begin : L
    assign w = int'(Y) + g;
    wire [7:0] n;
    assign n = 8'(Y);
  end
  if (X > 4) begin : G
    assign v = int'(Y);
  end
endmodule
module top();
  sub u0();
  sub #(.X(6)) u1();
endmodule
