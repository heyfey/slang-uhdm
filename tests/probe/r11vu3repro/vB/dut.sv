package pb;
  typedef struct packed { logic [3:0] g; logic [3:0] h; } sb_t;
endpackage
module leaf(output logic [3:0] o); parameter int P = 0; assign o = P[3:0]; endmodule
module mid(output logic [3:0] o);
  parameter pb::sb_t C = 8'b00000000;
  leaf #(.P(C.g)) u (.o(o));
endmodule
module top(output logic [3:0] o1, output logic [3:0] o2);
  mid u1 (.o(o1));
  mid #(.C(8'b10100101)) u2 (.o(o2));
endmodule
