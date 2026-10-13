// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top #(parameter bit E = 0) (output logic [1:0] o);
  ifc inst ();
  if (E) begin : gi
    child c (.p(inst), .o(o[0]));
  end
  assign o = 2'b0;
endmodule
