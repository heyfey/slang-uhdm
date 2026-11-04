// § ifaceTailDupGenChild309
interface pif #(parameter int W = 4);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface
module child (pif.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic o);
  pif #(.W(5)) inst ();
  if (1) begin : g
    child c (.p(inst), .o(o));
  end
endmodule
