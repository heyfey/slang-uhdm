// § unsignedScalarVecTsAtKeyword137
module sub(output logic o);
  wire logic unsigned w;
  assign w = 1'b1;
  assign o = w;
endmodule
module top(output logic o);
  sub u(.o(o));
endmodule
