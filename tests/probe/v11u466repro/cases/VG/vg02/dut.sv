// § genIfcViewSharesParamAssigns466
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
endinterface
module s(interface bus, output logic o);
  assign o = bus.d[0];
endmodule
module top(output logic o1, output logic o2);
  bif #(.W(6)) M();
  bif #(.W(8)) N();
  s d1(.bus(M), .o(o1));
  s d2(.bus(N), .o(o2));
endmodule
