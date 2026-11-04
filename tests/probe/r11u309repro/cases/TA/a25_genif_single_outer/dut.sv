// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [1:0] o);
  ifc inst ();
  if (1) begin : gi
    child c (.p(inst), .o(o[0]));
  end
  assign o[1] = 1'b0;
endmodule
