// § genIfaceParentAtBirth313
interface ifc0;
  logic sig;
endinterface
module c0 (ifc0 p, output logic o);
  assign o = p.sig;
endmodule
module top (output logic o);
  if (1) begin : g
    ifc0 u ();
    c0 c (.p(u), .o(o));
  end
endmodule
