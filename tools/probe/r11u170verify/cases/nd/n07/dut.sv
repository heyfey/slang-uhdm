// § elabTpNamedElemDimDefNamed163
module child #(
    parameter type id_t = logic,
    parameter int DEPTH = 4,
    localparam type rt_t = id_t [DEPTH-1:0]
) (input rt_t rt_i, output id_t o);
  assign o = rt_i[DEPTH-1];
endmodule
module top (input logic [7:0] a, output logic [1:0] o [2], input logic [3:0] b, output logic p);
  for (genvar g = 0; g < 2; g++) begin : G
    child #(.id_t(logic [1:0])) u(.rt_i(a), .o(o[g]));
  end
  child v(.rt_i(b), .o(p));
endmodule
