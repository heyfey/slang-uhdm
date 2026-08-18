// r10v61 VERIFIER GRID 5 -- and THE ARBITER'S OWN FALSE POSITIVE.
// `sect3way61.sh` reports AWAY-GOLDEN=1 on this arm; the OWNER-KEYED census
// (hccen61 / hc3.py) reports AWAY-GOLDEN=0 and the OFFICIAL uhdm-cmp logs are
// BYTE-IDENTICAL pristine vs patched.  The multiset row is
//   \_logic_var: (work@v5_v61.u1.sh)  golden=3 pristine=3 patched=2
// and the three edges are NOT the same three:
//   golden's 3rd  = gen_scope `gs`'s cont_assign `assign sh = ~clk;` (:19),
//                   whose LHS ref Surelog binds to the MODULE's `sh` and NOT
//                   to the gen block's own shadowing `sh` -- an edge NEITHER
//                   binary has ever had (PRE-EXISTING shortfall);
//   pristine's 3rd = `gt.i_out`'s HighConn operand, the edge law A correctly
//                   REMOVES.
// A count that is right for the wrong reason reads as a regression when the
// wrong reason is fixed.  Always key the census by OWNER before believing a
// line-multiset AWAY row.
// r10v61 ADVERSARIAL GRID 5 — law A: TOP-module generate scope, deep mixed
// nesting, name shadowing, gen-local nets vs vars, genvar-in-expression,
// struct-field operand, and an unnamed nested generate chain.
package pt61;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } st61_t;
endpackage

module kv61 (input logic a, output logic y);
  assign y = a;
endmodule

// E1: name SHADOWING -- a gen-local with the SAME name as a module signal
module m_e1 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic sh, yo, yp;
  assign sh = clk;
  if (EN) begin : gs
    logic sh;                       // shadows the module's sh
    assign sh = ~clk;
    kv61 i_in (.a(sh & sh), .y(yo));
  end
  if (EN) begin : gt
    kv61 i_out (.a(sh & sh), .y(yp));   // names the MODULE's sh
  end
  assign q = yo ^ yp;
endmodule

// E2: gen-local NET (wire) vs gen-local VAR
module m_e2 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yo, yp;
  if (EN) begin : gn
    wire  gw;
    logic gv;
    assign gw = clk;
    assign gv = ~clk;
    kv61 i_w (.a(gw & gw), .y(yo));
    kv61 i_v (.a(gv & gv), .y(yp));
  end
  assign q = yo ^ yp;
endmodule

// E3: for INSIDE if INSIDE for, operand from each level + the genvar
module m_e3 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic mv;
  logic [1:0][1:0] yy;
  for (genvar a = 0; a < 2; a++) begin : ga
    logic la;
    assign la = clk;
    if (EN) begin : gb
      logic lb;
      assign lb = clk;
      for (genvar c = 0; c < 2; c++) begin : gc
        logic lc;
        assign lc = clk;
        kv61 i_c (.a(lc & lb), .y(yy[a][c]));
      end
    end
  end
  assign q = yy[0][0];
endmodule

// E4: struct-FIELD operand of a gen-local struct and of a module struct
module m_e4 (input logic clk, output logic q);
  parameter bit EN = 1;
  import pt61::*;
  st61_t ms;
  logic yo, yp;
  if (EN) begin : gsf
    st61_t gsv;
    assign gsv = '{hi: 4'h1, lo: 4'h2};
    kv61 i_g (.a(gsv.hi[0] & clk), .y(yo));
    kv61 i_m (.a(ms.hi[0] & clk),  .y(yp));
  end
  assign q = yo ^ yp;
endmodule

// E5: TOP-module generate scope (this module IS the top of the design)
module v5_v61 (input logic clk, output logic o);
  parameter bit EN = 1;
  logic tv, tu, ty;
  logic o1,o2,o3,o4;
  if (EN) begin : gtop
    logic tl;
    assign tl = clk;
    kv61 i_top (.a(tv & tu), .y(ty));    // module signals from a TOP gen scope
    kv61 i_tl  (.a(tl & tl), .y());      // gen-local from a TOP gen scope
  end
  m_e1 u1 (.clk(clk), .q(o1));
  m_e2 u2 (.clk(clk), .q(o2));
  m_e3 u3 (.clk(clk), .q(o3));
  m_e4 u4 (.clk(clk), .q(o4));
  assign o = ty ^ o1 ^ o2 ^ o3 ^ o4;
endmodule
