// r10earl87 arm g2 — IMPORT KINDS x the same override.
//
// MEASURED FACT recorded here: an EXPLICIT `import pk2::QA;` in a module that
// also declares its own `QA` is a REDEFINITION error (slang rejects it;
// -Wredefinition).  A name collision between a materialized import copy and a
// module parameter can therefore ONLY arise from a WILDCARD import, which is
// why this law names wildcard imports and nothing else.
package pk2;
  localparam int QA = 21;
  localparam int QB = 22;
endpackage

// v1 WILDCARD body import, colliding name
module k1 #(parameter int QA = 1) (output logic [7:0] o);
  import pk2::*;
  assign o = QA[7:0] + QB[7:0];
endmodule

// v3 EXPLICIT body import of a NON-colliding name only
module k3 #(parameter int QA = 1) (output logic [7:0] o);
  import pk2::QB;
  assign o = QA[7:0] + QB[7:0];
endmodule

// v4 PACKAGE-QUALIFIED reference, NO import at all (no materialization)
module k4 #(parameter int QA = 1) (output logic [7:0] o);
  assign o = QA[7:0] + pk2::QA[7:0];
endmodule

// v5 HEADER wildcard import (before the parameter port list) — rstmgr_ctrl's shape
module k5 import pk2::*; #(parameter int QA = 1) (output logic [7:0] o);
  assign o = QA[7:0] + QB[7:0];
endmodule

// v6 the import lives in the PARENT only
module k6 #(parameter int QA = 1) (output logic [7:0] o);
  assign o = QA[7:0];
endmodule

module top87 import pk2::*; (output logic [7:0] o1, o3, o4, o5, o6);
  k1 #(.QA(7)) u_k1 (.o(o1));
  k3 #(.QA(7)) u_k3 (.o(o3));
  k4 #(.QA(7)) u_k4 (.o(o4));
  k5 #(.QA(7)) u_k5 (.o(o5));
  k6 #(.QA(7)) u_k6 (.o(o6));
endmodule
