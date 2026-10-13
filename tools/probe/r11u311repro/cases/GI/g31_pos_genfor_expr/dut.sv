// § ifaceElemPosSelWholeSpan311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc farr [4] ();
  for (genvar i = 0; i < 2; i++) begin : gc
    child c (farr[2*i+1], o[i]);
  end
endmodule
