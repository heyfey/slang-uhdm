// § genIfcViewSharesParamAssigns466
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
endinterface
module s #(parameter int K = 1) (interface bus, output logic o);
  assign o = bus.d[K];
endmodule
module top(output logic o);
  bif M();
  s #(.K(2)) dut(.bus(M), .o(o));
endmodule
