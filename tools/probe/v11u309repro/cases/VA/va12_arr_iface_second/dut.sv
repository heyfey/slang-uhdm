// § ifaceTailDupArrayChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [3:0] o);
  ifc i0 ();
  ifc i1 ();
  child a1 [2] (.p(i1), .o(o[1:0]));
  child a2 [2] (.p(i0), .o(o[3:2]));
endmodule
