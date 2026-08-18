// v12 — instance ARRAYS as the HOME.  A child instance ARRAY inside a gen-for,
// and a child instance array at module scope whose actual is an interface
// instance array element.  The gate walks PAST InstanceArray scopes; if that
// walk is wrong these cells move the wrong way.
interface ifc #(parameter int W = 8, parameter int D = 2);
  logic [W-1:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [7:0] o);
  ifc #(16, 3) inst ();
  ifc #(16, 3) arr [2] ();
  child a1 [2] (.p(inst), .o(o[1:0]));         // instance array, module scope
  child a2 [2] (.p(arr),  .o(o[3:2]));         // instance array fed by an iface array
  for (genvar i = 0; i < 2; i++) begin : gf
    ifc #(16, 3) finst ();
    child a3 [2] (.p(finst), .o(o[5:4]));      // instance array in gen-for, actual INSIDE
    child a4 [2] (.p(inst),  .o(o[7:6]));      // instance array in gen-for, actual OUTSIDE
  end
endmodule
