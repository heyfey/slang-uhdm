// § defGenModArraySizeRange309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : gf
    ifc finst ();
    child a3 [1+1] (.p(finst), .o(o[2*i+1:2*i]));
  end
endmodule
