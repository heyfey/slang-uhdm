// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
interface outer (ifc p);
  logic t;
  assign t = p.sig[0];
endinterface
module top (output logic o);
  ifc inst ();
  if (1) begin : g
    outer oi (.p(inst));
  end
  assign o = g.oi.t;
endmodule
