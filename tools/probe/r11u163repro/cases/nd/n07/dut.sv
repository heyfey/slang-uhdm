// § elabTpDefaultDefNamed163
module child #(
    parameter int W = 8,
    parameter type data_t = logic [W-1:0]
) (input data_t d, output data_t q);
  data_t r;
  assign r = d;
  assign q = r;
endmodule
module dut (input logic [3:0] a, output logic [3:0] b, input logic [7:0] c, output logic [7:0] e);
  child #(.W(4)) u1 (.d(a), .q(b));
  child #(.data_t(logic [7:0])) u2 (.d(c), .q(e));
endmodule
