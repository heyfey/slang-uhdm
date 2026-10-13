// § ifaceConnNetArrayChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module child2 (ifc.mp p, ifc.mp q, output logic o);
  assign o = p.sig[0] ^ q.sig[0];
endmodule
module top (output logic [2:0] o);
  ifc i1 ();
  ifc i2 ();
  child2 a1 [2] (.p(i1), .q(i2), .o(o[1:0]));
  child c0 (.p(i2.mp), .o(o[2]));
endmodule
