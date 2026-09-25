module top(input pa::s_t i, output logic o, output logic p);
  assign o = pb::f(i);
  assign p = pc::g(i);
endmodule
