// § genIfcViewSharesParamAssigns466
package p;
  parameter int NB = 100;
endpackage
interface bif;
  import p::*;
  logic [3:0] d;
endinterface
module s(bif bus, output logic o);
  assign o = bus.d[0];
endmodule
module top(output logic o);
  bif M();
  s dut(.bus(M), .o(o));
endmodule
