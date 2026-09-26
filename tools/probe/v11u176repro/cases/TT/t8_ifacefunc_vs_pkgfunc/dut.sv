// § tdKeyKeepsUnresolved176v
module dut(input pa::s_t i, output logic o, p);
  ifc u ();
  assign o = pb::f(i);
  assign p = u.g(i);
endmodule
