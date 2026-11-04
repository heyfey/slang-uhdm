// § ovrMultiDimConstUnparented131
// case o01: an overridden three-dimensional packed parameter
module sub #(parameter logic [1:0][1:0][3:0] M = '0) (output logic [15:0] o);
  assign o = M;
endmodule
module top(output logic [15:0] o);
  sub #(.M(16'hBEEF)) u(.o(o));
endmodule
