package pl;
  typedef struct packed { logic [3:0] g; logic [3:0] h; } sl_t;
endpackage
module leaf(output logic [3:0] o); parameter logic [3:0] P = 0; assign o = P; endmodule
module mid(output logic [3:0] o);  parameter int P = 0;          leaf #(.P(P)) u (.o(o)); endmodule
module mid2(output logic [3:0] o); parameter logic [7:0] P = 0;  leaf #(.P(P)) u (.o(o)); endmodule
module top(output logic [3:0] o1, output logic [3:0] o2);
  parameter pl::sl_t C = 8'b10100101;
  mid  #(.P(C.g)) u1 (.o(o1));
  mid2 #(.P(C.h)) u2 (.o(o2));
endmodule
