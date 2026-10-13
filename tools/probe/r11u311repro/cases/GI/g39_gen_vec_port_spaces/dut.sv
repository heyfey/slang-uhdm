// § ifaceElemIdxTextTrim311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc fi ();
  for (genvar i = 0; i < 2; i++) begin : gc
    child c (.p(fi), .o(o[ i ]));
  end
endmodule
