// § ifaceConnNetArrayChild309
interface pif #(parameter int W = 4);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface
module child (pif.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [3:0] o);
  pif #(.W(3)) inst ();
  child a1 [2] (.p(inst), .o(o[1:0]));
  child a2 [2] (.p(inst), .o(o[3:2]));
endmodule
