// § ifaceTailDupArrayChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc p, output logic o);
  assign o = p.sig[1];
endmodule
module top (output logic [1:0] o);
  ifc inst ();
  child a1 [2] (.p(inst), .o(o));
endmodule
