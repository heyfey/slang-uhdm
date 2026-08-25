// r10earl87 arm g4 — HOMES.  The same collision inside a generate-if scope, a
// generate-for scope, an interface, and nested instances one/two/three deep.
package pk4;
  localparam int SA = 41;
  localparam int SB = 42;
endpackage

interface ifc4 #(parameter int SA = 1) ();
  import pk4::*;
  logic [7:0] v;
  assign v = SA[7:0] + SB[7:0];
endinterface

module deep3 #(parameter int SA = 1) (output logic [7:0] o);
  import pk4::*;
  assign o = SA[7:0] + SB[7:0];
endmodule

module deep2 #(parameter int SA = 1) (output logic [7:0] o);
  import pk4::*;
  deep3 #(.SA(SA + 1)) u3 (.o(o));
endmodule

module deep1 #(parameter int SA = 1) (output logic [7:0] o);
  import pk4::*;
  deep2 #(.SA(SA + 1)) u2 (.o(o));
endmodule

module gleaf #(parameter int SA = 1) (output logic [7:0] o);
  import pk4::*;
  assign o = SA[7:0] + SB[7:0];
endmodule

module top87 (output logic [7:0] o1, o2, o3, o4);
  deep1 #(.SA(7)) u_d1 (.o(o1));

  ifc4 #(.SA(7)) u_if ();
  assign o2 = u_if.v;

  if (1) begin : g_if
    gleaf #(.SA(7)) u_g (.o(o3));
  end

  logic [7:0] fo [0:1];
  for (genvar gi = 0; gi < 2; gi++) begin : g_for
    gleaf #(.SA(7 + gi)) u_f (.o(fo[gi]));
  end
  assign o4 = fo[0] + fo[1];
endmodule
