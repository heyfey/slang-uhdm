// § unsignedScalarVecTsAtKeyword137
module sub #(parameter type T = bit unsigned)(output logic o);
  T x;
  assign o = x;
endmodule
module top(output logic o);
  sub u(.o(o));
endmodule
