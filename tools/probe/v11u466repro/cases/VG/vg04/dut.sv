// § genIfcViewSharesParamAssigns466
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
endinterface
module s(interface bus, output logic o);
  assign o = bus.d[0];
endmodule
module top(output logic o);
  bif #(.W(6)) M[2]();
  s dut(.bus(M[1]), .o(o));
endmodule
