// r10v87 arm va12 — an IMPLICIT parameter port (the `data_type
// list_of_param_assignments` form, no `parameter` keyword) colliding with a
// wildcard-imported package member.  isImplicitPortParam is exact for these and
// Surelog re-creates them AFTER the body params in the elaborated instance.
package pi12;
  localparam int IA = 141;
  localparam int IB = 142;
endpackage

module ileaf #(int unsigned IA = 1, int unsigned ID = 4) (output logic [7:0] o);
  import pi12::*;
  assign o = IA[7:0] + IB[7:0] + ID[7:0];
endmodule

module top87 (output logic [7:0] o1, o2);
  ileaf #(.IA(7))  u_a (.o(o1));
  ileaf #(.ID(9))  u_d (.o(o2));
endmodule
