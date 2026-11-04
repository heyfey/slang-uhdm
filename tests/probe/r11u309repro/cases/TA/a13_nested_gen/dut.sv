// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [7:0] o);
  ifc inst ();
  for (genvar i = 0; i < 2; i++) begin : gf
    for (genvar j = 0; j < 2; j++) begin : gg
      child a5 [2] (.p(inst), .o(o[4*i+2*j+1:4*i+2*j]));
    end
  end
endmodule
