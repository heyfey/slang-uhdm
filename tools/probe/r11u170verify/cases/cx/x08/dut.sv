// § elabTpDefaultDefNamed163 § tpUseBindsDefDefault160
module ram #(parameter int W = 8, parameter type data_t = logic [W-1:0]) (output logic [7:0] o);
  localparam int B = $bits(data_t);
  assign o = 8'(B);
endmodule
module top (output logic [7:0] o); ram u(.o(o)); endmodule
