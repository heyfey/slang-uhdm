// § implNetBareParamElab160
module sub #(parameter logic P = 1'b1) (output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : G
    assign w = P;
    assign o[i] = w;
  end
endmodule
module top (output logic [1:0] o); sub #(.P(1'b0)) u(.o(o)); endmodule
