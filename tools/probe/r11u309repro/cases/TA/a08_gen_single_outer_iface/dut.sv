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
  for (genvar i = 0; i < 2; i++) begin : gf
    child a4 (.p(inst), .o(o[i]));
  end
endmodule
