// § ifaceConnNetArrayChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, ifc.mp q, output logic o);
  assign o = p.sig[0] & q.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc ia ();
  ifc ib ();
  child a1 [2] (.q(ib), .p(ia), .o(o));
endmodule
