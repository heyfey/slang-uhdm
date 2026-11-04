// § unsignedScalarVecTsAtKeyword137
module top(output logic o);
  bit unsigned x = 1'b1;
  logic unsigned y = 1'b0;
  assign o = x ^ y;
endmodule
