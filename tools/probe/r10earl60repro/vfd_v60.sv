// v60 VERIFIER arm D — IMPORT variety beyond v60d's wildcard case: an EXPLICIT
// single-name import, an import of the very member referenced, a package that
// re-exports through a wildcard import, and a module that imports a package
// and then refers to a DIFFERENT package by explicit scope.
package ip_src;
  localparam int          SA = 8;
  localparam logic [11:0] SB = 12'h380;
endpackage
package ip_mid;
  import ip_src::*;                     // wildcard: re-export shape
  localparam int MA = SA;               // bare ref to the imported name
  localparam int MB = ip_src::SA;       // explicitly scoped
  localparam int MC = 4;
endpackage
package ip_other;
  localparam int OA = 3;
endpackage

module s_expimp ();
  import ip_src::SA;                    // EXPLICIT single-name import
  localparam int e1 = SA;               // bare ref to the explicitly imported
  localparam int e2 = ip_src::SA;       // same member, explicitly scoped
  logic [e1-1:0] d;
endmodule

module s_midimp ();
  import ip_mid::*;                     // materializes MA/MB/MC here
  localparam int m1 = ip_mid::MA;       // module-declared, source = ip_mid
  localparam int m2 = ip_src::SA;       // module-declared, source = ip_src
  logic [MC-1:0] d;
endmodule

module s_mixed ();
  import ip_other::*;
  localparam int x1 = ip_src::SA;       // imports one pkg, refers to another
  localparam int x2 = ip_other::OA;
  logic [x1-1:0] d;
endmodule

module a1 ();
  s_expimp u0 ();
  s_midimp u1 ();
  s_mixed  u2 ();
endmodule
