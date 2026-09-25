// § elabTpDefaultDefNamed163 § tpUseBindsDefDefault160
module ram #(parameter int W = 8, parameter type data_t = logic [W-1:0]) (input data_t d, output data_t q);
  assign q = d;
endmodule
module top (input logic [7:0] d, output logic [7:0] q); ram u(.d(d), .q(q)); endmodule
