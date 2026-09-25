// § elabTpNamedElemDimDefNamed163
module child #(
    parameter type id_t = logic,
    parameter int N = 3,
    parameter type rt_t = id_t [N-1:0]
) (input rt_t rt_i, output id_t o);
  assign o = rt_i[0];
endmodule
module top(input logic [7:0] a, output logic [1:0] o1);
  child #(.id_t(logic [1:0]), .N(4)) u(.rt_i(a), .o(o1));
endmodule
