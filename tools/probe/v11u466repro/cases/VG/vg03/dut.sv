// § genIfcViewSharesParamAssigns466
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp(input d);
endinterface
module s(interface.mp bus, output logic o);
  assign o = bus.d[0];
endmodule
module top(output logic o);
  bif #(.W(6)) M();
  s dut(.bus(M), .o(o));
endmodule
