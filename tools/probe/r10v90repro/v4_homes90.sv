// r10v90 v4 — HOMES AND CONTEXTS the implementer's grids do not reach: a
// module instantiated INSIDE AN INTERFACE's generate scope, a gen-CASE, a
// gen-if nested in a gen-for, an INSTANCE ARRAY inside a gen scope, a
// THREE-DEEP instance chain that must keep the ref at every level, an
// interface PORT actual, a MODPORT-rooted select, a select in a hier_path
// WIDTH, a select as a USER-CALL argument (MUST STAY), a nested select whose
// outer bound is a part_select RANGE bound (`Reduce::No`, MUST STAY), and the
// same width read on an OUTPUT and an INOUT port.
module snk4_90 (input logic [3:0] a_i);
endmodule
module snk4o90 (output logic [3:0] b_o);
  assign b_o = 4'h0;
endmodule
module snk4io90 (inout wire [3:0] c_io);
endmodule

function automatic logic [3:0] uf90(input logic [3:0] x);
  return x;
endfunction

interface iv90 ();
  localparam int IP4 = 4;
  logic [31:0] w;
  modport mp (input w);
  // (slang refuses a module instantiation inside an interface, so the
  // interface home is exercised through the modport user below instead.)
endinterface

module deep90 (input logic [31:0] s_i);
  localparam int D4 = 4;
  for (genvar g = 0; g < 1; g++) begin : gd
    snk4_90 u_lf (.a_i(s_i[g*4 +: D4]));
  end
endmodule
module mid2_90 (input logic [31:0] s_i);
  deep90 u_dp (.s_i(s_i));
endmodule
module top2_90 (input logic [31:0] s_i);
  mid2_90 u_md (.s_i(s_i));
endmodule

module usemp90 (iv90.mp p);
  localparam int M4 = 4;
  for (genvar g = 0; g < 1; g++) begin : gmp
    snk4_90 u_mp (.a_i(p.w[g*4 +: M4]));
  end
endmodule

module v4_homes90;
  localparam int P4 = 4;
  localparam int P2 = 2;
  logic [31:0] sig;
  logic [31:0] arr2 [0:3];
  wire  [31:0] wsig;
  typedef struct packed { logic [15:0] hi; logic [15:0] lo; } sv90_t;
  sv90_t st;

  iv90 u_if ();

  // (1) an interface PORT actual + a MODPORT-rooted select inside it.
  usemp90 u_ump (.p(u_if.mp));

  // (2) a THREE-DEEP instance chain.
  top2_90 u_t2 (.s_i(sig));

  for (genvar g = 0; g < 1; g++) begin : gf
    // (3) a gen-if NESTED in a gen-for.
    if (1) begin : gnest
      snk4_90 n01 (.a_i(sig[g*4 +: P4]));
    end
    // (4) an INSTANCE ARRAY inside a gen scope.
    snk4_90 n02 [0:1] (.a_i(sig[g*4 +: P4]));
    // (5) OUTPUT and INOUT port actuals.
    snk4o90  n03 (.b_o(sig[g*4 +: P4]));
    snk4io90 n04 (.c_io(wsig[g*4 +: P4]));
    // (6) a hier_path (dotted) actual, WIDTH slot.
    snk4_90 n05 (.a_i(st.lo[g*4 +: P4]));
    // (7) an interface member read, WIDTH slot.
    snk4_90 n06 (.a_i(u_if.w[g*4 +: P4]));
    // (8) a USER-CALL argument — MUST STAY a ref_obj.
    snk4_90 n07 (.a_i(uf90(sig[g*4 +: P4])));
    // (9) an UNPACKED element then a packed ips (nested select).
    snk4_90 n08 (.a_i(arr2[g][P2 +: P2*2]));
    // (10) a part_select whose bounds are params — MUST STAY refs.
    snk4_90 n09 (.a_i(sig[g*4+P4-1 : g*4]));
    snk4_90 n10 (.a_i(sig[P4+3 : P4]));
    // (11) a CONCATENATION of two ips widths in one actual.
    snk4_90 n11 (.a_i({sig[g*4 +: P2], sig[g*8 +: P2]}));
    // (12) a REPLICATION around the select.
    snk4_90 n12 (.a_i({2{sig[g*4 +: P2]}}));
    // (13) a TERNARY around the select.
    snk4_90 n13 (.a_i(g == 0 ? sig[g*4 +: P4] : sig[g*8 +: P4]));
  end

  // (14) a gen-CASE.
  case (P4)
    4: begin : gcase
      snk4_90 n14 (.a_i(sig[0 +: P4]));
    end
    default: begin : gcased
      snk4_90 n15 (.a_i(sig[4 +: P4]));
    end
  endcase
endmodule
