// r10v87 arm va9 — a RE-EXPORT chain: pinner is wildcard-imported by pouter,
// pouter is wildcard-imported by the module.  The materialized copy carries
// vpiImported = the IMMEDIATELY imported package, and its name collides with an
// overridden formal.
package pinner;
  localparam int ZA = 111;
  localparam int ZI = 112;
endpackage
package pouter;
  import pinner::*;
  export pinner::*;
  localparam int ZO = 113;
endpackage

module rleaf #(parameter int ZA = 1, parameter int ZO = 2) (output logic [7:0] o);
  import pouter::*;
  assign o = ZA[7:0] + ZO[7:0];
endmodule

module top87 (output logic [7:0] o1, o2);
  rleaf #(.ZA(7))            u_a (.o(o1));
  rleaf #(.ZO(8))            u_o (.o(o2));
endmodule
