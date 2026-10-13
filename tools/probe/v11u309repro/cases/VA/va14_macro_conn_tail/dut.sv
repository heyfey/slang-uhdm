// § ifaceTailDupArrayChild309
`define IFN inst
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc inst ();
  child a1 [2] (.p(`IFN), .o(o));
endmodule
