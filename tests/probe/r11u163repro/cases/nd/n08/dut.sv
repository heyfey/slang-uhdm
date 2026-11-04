// § elabTpDefaultDefNamed163
module child #(
    parameter int W = 8,
    parameter type data_t = logic [W-1:0]
) (input data_t d, output logic o);
  assign o = ^d;
endmodule
module dut (input logic [7:0] a, output logic o);
  child u (.d(a), .o(o));
endmodule
