// r10v87 arm va7 — the override is TEXTUALLY the default (same value) and, in
// the second instance, a BARE REF to a parent parameter (Surelog's
// exprtype == uhdmref_obj branch, DesignElaboration.cpp:2309-2327).
package ps7;
  localparam int XA = 101;
  localparam int XB = 102;
endpackage

module xleaf #(parameter int XA = 5, parameter int XD = 6) (output logic [7:0] o);
  import ps7::*;
  assign o = XA[7:0] + XB[7:0] + XD[7:0];
endmodule

module xmid #(parameter int PTOP = 9) (output logic [7:0] o1, o2);
  xleaf #(.XA(5))    u_same (.o(o1));   // override == the default text
  xleaf #(.XA(PTOP)) u_ref  (.o(o2));   // bare ref to a parent parameter
endmodule

module top87 (output logic [7:0] o1, o2);
  xmid #(.PTOP(7)) u_m (.o1(o1), .o2(o2));
endmodule
