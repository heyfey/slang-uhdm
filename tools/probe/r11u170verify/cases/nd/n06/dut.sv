// § elabTpNamedElemDimDefNamed163
module child #(
    parameter type id_t = logic,
    parameter int A = 2,
    parameter int B = 2,
    localparam type rt_t = id_t [A-1:0][B-1:0]
) (input rt_t rt_i, output id_t o);
  assign o = rt_i[1][0];
endmodule
module top (input logic [15:0] a, output logic [3:0] o1);
  child #(.id_t(logic [3:0])) u(.rt_i(a), .o(o1));
endmodule
