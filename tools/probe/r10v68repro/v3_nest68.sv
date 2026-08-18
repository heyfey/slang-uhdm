// r10v68 arm v3 — the NESTING/BINDING dimension: 1..3 genvars nested, gen-if
// under gen-for under gen-if, UNNAMED generate blocks, CASE-generate,
// interface gen scopes, 1..3 unrollings x 1..3 child instances, and the
// module/package parameter NEGATIVE controls the generate-only walk must
// never take.  MEASUREMENT ONLY.
package v3_pkg68;
  parameter int unsigned PkgP = 6;
endpackage

interface v3_if68;
  logic [7:0] iw;
  for (genvar i = 0; i < 3; i++) begin : g_i
    if (i >= 0) begin : b1
      if (i >= 0) begin : b2
        logic [7:0] deep;
        assign deep = i;                  // interface gen scope, distance 2
      end
    end
  end
endinterface

module v3_kid68 #(parameter int unsigned KP = 0) (output logic [7:0] o);
  logic [7:0] kv;
  for (genvar i = 0; i < 3; i++) begin : g_k
    if (i >= 0) begin : b1
      if (i >= 0) begin : b2
        assign kv = i;                    // distance 2 inside a CHILD
      end
    end
  end
  assign o = kv ^ KP[7:0];
endmodule

module v3_nest68 #(parameter int unsigned MP = 5) (input logic [7:0] din, output logic [7:0] dout);
  import v3_pkg68::*;
  localparam int unsigned MLp = 7;
  logic [7:0] t3, t_un, t_cs, t_mp, t_pp, t_lp, o0, o1, o2;
  logic [7:0] u1, u2, u3;

  // THREE nested genvars, read at every distance.
  for (genvar i = 0; i < 2; i++) begin : g_a
    for (genvar j = 0; j < 2; j++) begin : g_b
      for (genvar k = 0; k < 2; k++) begin : g_c
        assign t3 = i + j + k;
        if (k >= 0) begin : b1
          logic [7:0] vi, vj, vk;
          assign vi = i;                  // OUTERMOST genvar, distance 3
          assign vj = j;                  // middle, distance 2
          assign vk = k;                  // innermost, distance 1
        end
      end
    end
  end

  // gen-if UNDER gen-for UNDER gen-if, with UNNAMED blocks in the chain.
  if (MP > 0) begin : g_out
    for (genvar i = 0; i < 2; i++) begin      // UNNAMED loop body
      if (i >= 0) begin                       // UNNAMED if body
        logic [7:0] uv;
        assign uv   = i;                      // unnamed chain, distance 2
        assign t_un = i;                      // module-level Lhs
      end
    end
  end

  // CASE-generate in the chain.
  for (genvar i = 0; i < 3; i++) begin : g_cs
    case (i)
      0: begin : c0 assign t_cs = i; end
      1: begin : c1 assign t_cs = i; end
      default: begin : cd assign t_cs = i; end
    endcase
  end

  // NEGATIVE controls: a MODULE parameter, a PACKAGE parameter and a real
  // gen-block LOCALPARAM read as the whole Rhs from inside gen blocks.
  for (genvar i = 0; i < 2; i++) begin : g_ng
    localparam int unsigned GLp = i + 1;
    if (i >= 0) begin : b1
      assign t_mp = MP;                       // module parameter
      assign t_pp = PkgP;                     // package parameter
      assign t_lp = GLp;                      // real gen localparam
    end
  end

  // 1..3 unrollings x 1..3 child instances.
  v3_kid68 #(.KP(1)) k_a (.o(o0));
  v3_kid68 #(.KP(2)) k_b (.o(o1));
  v3_kid68 #(.KP(3)) k_c (.o(o2));
  v3_if68 the_if ();

  assign u1 = the_if.g_i[0].b1.b2.deep;
  assign u2 = the_if.g_i[1].b1.b2.deep;
  assign u3 = g_a[0].g_b[0].g_c[0].b1.vi;

  assign dout = t3 ^ t_un ^ t_cs ^ t_mp ^ t_pp ^ t_lp ^ o0 ^ o1 ^ o2 ^
                u1 ^ u2 ^ u3 ^ din ^ MLp[7:0];
endmodule
