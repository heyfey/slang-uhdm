// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [3:0] o);
  ifc inst ();
  child a0 (.p(inst), .o(o[3]));
  if (1) begin : gi
    child a4 [2] (.p(inst), .o(o[1:0]));
  end
endmodule
