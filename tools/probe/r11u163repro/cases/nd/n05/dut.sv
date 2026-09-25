// § elabTpNamedElemDimDefNamed163
module child #(
    parameter int  N     = 4,
    parameter type e_t   = byte,
    localparam type a_t  = e_t [N-1:0]
) (input a_t x, output logic o);
  assign o = x[0][0];
endmodule
module dut (input logic [15:0] x, output logic o);
  child #(.N(2)) u (.x(x), .o(o));
endmodule
