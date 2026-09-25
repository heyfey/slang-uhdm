// § elabTpNamedElemDimDefNamed163
module child #(
    parameter type id_t = logic,
    parameter int N = 3,
    localparam type rt_t = id_t [N-1:0]
) (input rt_t rt_i, output id_t o);
  assign o = rt_i[0];
endmodule
module top(input logic [5:0] a, output logic [1:0] o1, input logic [2:0] b, output logic o2);
  child #(.id_t(logic [1:0])) u(.rt_i(a), .o(o1));
  child v(.rt_i(b), .o(o2));
endmodule
