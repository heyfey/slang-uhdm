// § ifaceTailDupArrayChild309
interface pif #(parameter int W = 4);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface
module child (pif.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  pif #(.W(6)) inst ();
  child a1 [2] (.p(inst), .o(o));
endmodule
