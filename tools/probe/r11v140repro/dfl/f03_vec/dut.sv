// § defaultFillOneConstant140
module sub #(parameter logic [3:0] A[4] = '{default: 4'hF}) (output logic [3:0] o);
  assign o = A[2];
endmodule
module top(output logic [3:0] o); sub u(.o(o)); endmodule
