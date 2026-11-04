// § elabTpNamedElemDimDefNamed163
module child #(
    parameter type id_t  = logic,
    localparam int DEPTH = (1 << $bits(id_t)),
    localparam type rt_t = id_t [DEPTH-1:0]
) (input rt_t rt_i, output logic o);
  assign o = rt_i[0];
endmodule
module dut (input logic [7:0] a, output logic [1:0] o);
  for (genvar g = 0; g < 2; g++) begin : gb
    child #(.id_t(logic [1:0])) u (.rt_i(a), .o(o[g]));
  end
endmodule
