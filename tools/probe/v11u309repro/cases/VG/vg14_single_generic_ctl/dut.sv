// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (interface p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic o);
  ifc inst ();
  child c (.p(inst), .o(o));
endmodule
