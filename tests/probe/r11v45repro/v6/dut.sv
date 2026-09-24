// v6 — chain re-passed across a HIERARCHY HOP: the parent's type parameter is
// the child's override actual, and the child chains off it.
module leaf #(
    parameter type x_t = logic,
    parameter type y_t = x_t
) ( input y_t i, output logic o );
  assign o = ^i;
endmodule
module mid #(
    parameter type p_t = logic [1:0]
) ( input p_t i, output logic o );
  leaf #(.x_t(p_t)) u ( .i(i), .o(o) );
endmodule
module dut ( input logic [1:0] i, output logic o );
  mid #(.p_t(logic [1:0])) u ( .i(i), .o(o) );
endmodule
