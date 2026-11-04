// § ifaceTailDupArrayChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [3:0] o);
  ifc inst ();
  child s0 (.p(inst.mp), .o(o[0]));
  for (genvar i = 0; i < 1; i++) begin : gf
    child a1 [2] (.p(inst), .o(o[2:1]));
  end
endmodule
