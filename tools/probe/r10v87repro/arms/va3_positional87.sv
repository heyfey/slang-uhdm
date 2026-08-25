// r10v87 arm va3 — POSITIONAL (ordered) overrides.  Surelog takes a DIFFERENT
// branch for these (DesignElaboration.cpp:2301-2364): the name comes from
// `moduleParams[index]`, a vector built from the module FileContent's
// paParam_assignment nodes, and setOverridenParam is called only when the
// value evaluates VALID (or the operation branch runs).  Import copies come
// from the package's FileContent, so they must not enter that vector.
package pp3;
  localparam int TA = 71;
  localparam int TB = 72;
endpackage

module pleaf #(parameter int TA = 1, parameter int TB = 2, parameter int TD = 4)
              (output logic [7:0] o);
  import pp3::*;
  localparam int TE = TA + TB;
  assign o = TA[7:0] + TB[7:0] + TD[7:0] + TE[7:0];
endmodule

module top87 (output logic [7:0] o1, o2);
  pleaf #(7)       u_p1 (.o(o1));      // TA only
  pleaf #(7, 8, 9) u_p3 (.o(o2));      // TA, TB, TD
endmodule
