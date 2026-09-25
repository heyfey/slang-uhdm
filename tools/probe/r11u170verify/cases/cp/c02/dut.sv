// § implNetBareParamElab160
package pk; parameter logic P = 1'b1; endpackage
module sub (output logic o);
  assign w = pk::P;
  assign o = w;
endmodule
module top (output logic o); sub u(.o(o)); endmodule
