// § genIfcViewSharesParamAssigns466
package p;
  parameter int NB = 100;
endpackage
interface bif;
  import p::*;
  parameter int K = 3;
  logic [K-1:0] d;
endinterface
module s(interface bus, output logic o);
  assign o = bus.d[0];
endmodule
module top(output logic o);
  bif M();
  s dut(.bus(M), .o(o));
endmodule
