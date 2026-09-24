// § unsignedScalarVecTsAtKeyword137
module sub(output logic o);
  var logic unsigned v;
  logic unsigned l;
  reg unsigned r;
  assign v = 1'b1;
  assign l = v;
  assign r = l;
  assign o = r;
endmodule
module top(output logic o);
  sub u(.o(o));
endmodule
