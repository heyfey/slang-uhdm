// § defNetEndOnlyLoc130
module sub #(parameter type T = logic [3:0]) (output logic o);
  T [1:0] x;
  assign x = '0;
  assign o = x[0][0];
endmodule
module top(output logic o);
  sub #(.T(logic [2:0])) u(.o(o));
endmodule
