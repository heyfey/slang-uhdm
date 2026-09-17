// v11u56 ADVERSARIAL arm x5 — SCOPES AND OVERRIDES.  The law mutates the Rhs
// constant IN PLACE at the pass-54 mint, which runs PER ELABORATED INSTANCE.
// Two instances with DIFFERENT parameter overrides read the same member; a
// module-local localparam (not a package) supplies a third; a generate block
// supplies a fourth.  If any constant were shared across instances, the last
// writer would win and a cell would carry another instance's value.
package p;
  typedef enum logic [3:0] { E_A = 4'd2, E_B = 4'd9 } e_t;
  typedef struct packed {
    logic signed [31:0] s;
    e_t                 e;
    logic [31:0]        u;
  } cfg_t;
  localparam cfg_t A = '{s: -1, e: E_B, u: '1};
  localparam cfg_t B = '{s: -7, e: E_A, u: 3};
endpackage
module leaf #(parameter p::cfg_t C = p::A)
            (output logic signed [31:0] os, output logic [31:0] oe,
             output logic [31:0] ou);
  assign os = C.s;  assign oe = C.e;  assign ou = C.u;
endmodule
module locp (output logic signed [31:0] os, output logic [31:0] oe,
             output logic [31:0] ou);
  localparam p::cfg_t L = '{s: -3, e: p::E_B, u: '1};
  assign os = L.s;  assign oe = L.e;  assign ou = L.u;
endmodule
module dut (output logic signed [31:0] s1, output logic [31:0] e1, output logic [31:0] u1,
            output logic signed [31:0] s2, output logic [31:0] e2, output logic [31:0] u2,
            output logic signed [31:0] s3, output logic [31:0] e3, output logic [31:0] u3,
            output logic signed [31:0] s4, output logic [31:0] e4, output logic [31:0] u4);
  leaf u_a (.os(s1), .oe(e1), .ou(u1));
  leaf #(.C(p::B)) u_b (.os(s2), .oe(e2), .ou(u2));
  locp u_c (.os(s3), .oe(e3), .ou(u3));
  for (genvar g = 0; g < 1; g++) begin : gb
    leaf #(.C(p::B)) u_d (.os(s4), .oe(e4), .ou(u4));
  end
endmodule
