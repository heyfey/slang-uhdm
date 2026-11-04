// § ifaceTailDupArrayChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child #(parameter int K = 0) (ifc.mp p, output logic o);
  assign o = p.sig[K];
endmodule
module top (output logic [1:0] o);
  ifc inst ();
  child #(.K(3)) a1 [2] (.p(inst), .o(o));
endmodule
