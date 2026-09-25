// § elabTpNamedElemDimDefNamed163
module child #(
    parameter type id_t  = logic,
    parameter int  N     = 4,
    localparam type rt_t = id_t [N-1:0]
) (input rt_t rt_i, output logic o);
  rt_t r;
  assign r = rt_i;
  assign o = ^r;
endmodule
module dut (input logic [7:0] a, input logic [3:0] b, output logic o1, o2);
  child #(.id_t(logic [1:0])) u1 (.rt_i(a), .o(o1));
  child u2 (.rt_i(b), .o(o2));
endmodule
