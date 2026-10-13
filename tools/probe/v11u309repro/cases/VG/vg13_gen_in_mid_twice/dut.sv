// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module mid (output logic o);
  ifc inst ();
  if (1) begin : g
    child c (.p(inst), .o(o));
  end
endmodule
module top (output logic [1:0] o);
  mid m0 (.o(o[0]));
  mid m1 (.o(o[1]));
endmodule
