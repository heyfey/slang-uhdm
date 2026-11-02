// § genIfcViewSharesParamAssigns466
interface bif #(parameter int W = 4, parameter type T = logic);
  T [W-1:0] d;
endinterface
module s(interface bus, output logic o);
  assign o = bus.d[0];
endmodule
module top(output logic o);
  bif #(.W(3), .T(bit)) M();
  s dut(.bus(M), .o(o));
endmodule
