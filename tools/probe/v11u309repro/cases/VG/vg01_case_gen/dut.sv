// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top #(parameter int M = 1) (output logic o);
  ifc inst ();
  case (M)
    0: begin : c0 child c (.p(inst), .o(o)); end
    1: begin : c1 child c (.p(inst), .o(o)); end
  endcase
endmodule
