// r10v87 arm va4 — A TYPE PARAMETER whose name collides with a wildcard-
// imported package VALUE parameter.  Surelog's named-override path reaches
// `instance->setOverridenParam(name)` on the invalid-value branch
// (DesignElaboration.cpp:2288-2295) for a type override, so the NAME can be in
// the set while our predicate skips it (the patch tests
// `om7.kind != SymbolKind::Parameter`).
package py4;
  localparam int UA = 81;
  localparam int UT = 82;      // collides with the TYPE parameter's name
endpackage

module yleaf #(parameter type UT = int, parameter int UA = 1)
              (output logic [7:0] o);
  import py4::*;
  UT v;
  assign v = UA;
  assign o = v[7:0];
endmodule

module top87 (output logic [7:0] o1, o2);
  yleaf #(.UT(shortint), .UA(7)) u_t (.o(o1));
  yleaf #(.UA(7))                u_v (.o(o2));
endmodule
