// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp inst, output logic o);
  assign o = inst.sig[0];
endmodule
module top (output logic o);
  ifc inst ();
  if (1) begin : g
    child c (.inst, .o);
  end
endmodule
