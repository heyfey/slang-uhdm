// § caReduceLeavesOpKept475
// a net declaration assignment and a continuous assignment side by side
module top(output logic [3:0] y);
  parameter logic [3:0] A = 4'd3;
  parameter logic [3:0] B = 4'd5;
  wire [3:0] w = A ^ B;
  assign y = w;
endmodule
