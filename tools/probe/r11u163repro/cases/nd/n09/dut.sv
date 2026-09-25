// § elabTpDefaultDefNamed163
module child #(
    parameter int W = 8,
    parameter type data_t = struct packed { logic [W-1:0] a; logic b; }
) (input data_t d, output logic o);
  assign o = d.b;
endmodule
module dut (input logic [4:0] a, output logic o);
  child #(.W(4)) u (.d(a), .o(o));
endmodule
