// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [3:0] o);
  ifc farr [4] ();
  for (genvar i = 0; i < 4; i++) begin : gc
    child c (farr[i], o[i]);
  end
endmodule
