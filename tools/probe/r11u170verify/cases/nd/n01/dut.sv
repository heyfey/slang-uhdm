// § elabTpNamedElemDimDefNamed163
typedef logic [3:0] id_t;
module child #(parameter int A = 2, parameter int B = 3) (output logic [23:0] o);
  localparam type rt_t = id_t [A-1:0][B-1:0];
  rt_t rt_i;
  assign rt_i = '0;
  assign o = rt_i;
endmodule
module top (output logic [23:0] o); child u(.o(o)); endmodule
