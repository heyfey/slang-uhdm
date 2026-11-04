// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top #(parameter bit S = 0) (output logic o);
  ifc inst ();
  if (S) begin : gt
    child c (.p(inst), .o(o));
  end else begin : ge
    child c (.p(inst), .o(o));
  end
endmodule
