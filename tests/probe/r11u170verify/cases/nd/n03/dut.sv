// § elabTpDefaultDefNamed163
module ram #(parameter int DataWidth = 8, parameter type data_t = logic [DataWidth-1:DataWidth/2]) (output logic [7:0] o);
  data_t q;
  assign q = '1;
  assign o = 8'(q);
endmodule
module top (output logic [7:0] o); ram u(.o(o)); endmodule
