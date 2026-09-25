// § elabTpNamedElemDimDefNamed163
typedef logic [3:0] id_t;
module child #(parameter int DEPTH = 2) (output logic [15:0] o);
  localparam type rt_t = id_t [DEPTH-1:0];
  rt_t rt_i;
  assign rt_i = '0;
  assign o = 16'(rt_i);
endmodule
module mid #(parameter int D = 3) (output logic [15:0] o); child #(.DEPTH(D)) c(.o(o)); endmodule
module top (output logic [15:0] o, output logic [15:0] o2);
  mid m(.o(o));
  child c2(.o(o2));
endmodule
