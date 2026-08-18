// v3 — ARRAYS.  (a) an interface-ARRAY port `ifc.mp p [2]` fed the whole
// array; (b) an INSTANCE ARRAY of children `child u [2] (.p(inst))`;
// (c) the same two inside a gen-if.  The gate walks past InstanceArray
// scopes -- this cell is what proves that walk right or wrong.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module achild (ifc.mp p [2], output logic o);
  assign o = p[0].sig[0] ^ p[1].sig[0];
endmodule

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [5:0] o);
  ifc #(16, 3) arr [2] ();
  ifc #(16, 3) inst ();
  achild u1 (.p(arr), .o(o[0]));
  child  u2 [2] (.p(inst), .o(o[2:1]));
  if (1) begin : g
    achild u3 (.p(arr), .o(o[3]));
    child  u4 [2] (.p(inst), .o(o[5:4]));
  end
endmodule
