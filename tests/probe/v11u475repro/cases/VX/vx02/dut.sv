// § caReduceLeavesOpKept475
// a child instance with an override reading its own parameters
module sub #(parameter logic [3:0] A = 4'd3, parameter logic [3:0] B = 4'd5) (output logic [3:0] y, output logic q);
  assign y = A ^ B;
  assign q = A !== B;
endmodule
module top(output logic [3:0] y1, y2, output logic q1, q2);
  sub #(.A(4'd9)) u1(y1, q1);
  sub u2(y2, q2);
endmodule
