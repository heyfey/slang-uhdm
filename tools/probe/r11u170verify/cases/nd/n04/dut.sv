// § elabTpDefaultDefNamed163
module ram #(parameter int Depth = 16, parameter type addr_t = logic [$clog2(Depth)-1:0]) (output logic [7:0] o);
  addr_t q;
  assign q = '1;
  assign o = 8'(q);
endmodule
module top (output logic [7:0] o); ram u(.o(o)); endmodule
