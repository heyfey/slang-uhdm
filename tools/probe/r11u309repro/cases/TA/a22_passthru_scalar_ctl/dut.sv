// § ifaceTailDupArrayChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module mid (ifc.mp q, output logic [1:0] o);
  child a1 [2] (.p(q), .o(o));
endmodule
module top (output logic [1:0] o);
  ifc inst ();
  mid u (.q(inst), .o(o));
endmodule
