// § genIfcViewSharesParamAssigns466
package p;
  parameter int NB = 100;
  parameter int NY = (NB + 7) / 8;
endpackage
interface bif;
  import p::*;
  logic [NY-1:0] d;
endinterface
module s(interface bus, output logic o);
  assign o = bus.d[0];
endmodule
module top(output logic o);
  bif M();
  s dut(.bus(M), .o(o));
endmodule
