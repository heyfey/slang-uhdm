// r11u35 g4_view35 — THE VIEW and THE USE.  The same anonymous-aggregate type
// parameter default, reached through every listing the dump carries (the
// definition module, each elaborated instance, the typespec pool) and through
// every USE a member typespec can be reached by: a plain variable, a PORT, an
// assignment-pattern localparam of that type (the shape whose FLATTEN CLONE
// Surelog folds while keeping the declaration object symbolic — the corpus
// witnesses' own shape), a function-local variable, and a nested child module
// that re-passes the type.
package g4pk35;
  typedef struct packed { int unsigned XLEN; int unsigned VLEN; } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd64, VLEN: 32'd64};
endpackage

module g4leaf35 #(parameter type LT = struct packed { logic [7:0] a; })
                (input LT li, output LT lo);
  assign lo = li;
endmodule

module g4sub35 #(
    parameter g4pk35::cfg_t Cfg = g4pk35::DefaultCfg,
    parameter int unsigned  NU  = 5
) (
    input  logic                 a_i,
    output logic [Cfg.XLEN-1:0]  b_o
);
  // the corpus witnesses' declaration
  localparam type it_t = struct packed {
    logic [Cfg.XLEN-1:0] x;
    logic [Cfg.XLEN-1:0] y;
  };
  // ...and the assignment-pattern localparam that flattens a CLONE of it
  localparam it_t I = '{x: Cfg.XLEN'(1), y: Cfg.XLEN'(2)};
  assign b_o = a_i ? I.x : I.y;

  // the same default reached as a plain variable
  localparam type vv_t = struct packed { logic [NU-1:0] a; };
  vv_t vv;

  // ...as a function-local variable
  function automatic int unsigned f35(input int unsigned q);
    vv_t fv;
    fv.a = q[NU-1:0];
    return fv.a;
  endfunction
  localparam int unsigned FR = f35(3);

  // ...and re-passed to a child's own type parameter
  g4leaf35 #(.LT(vv_t)) u_leaf (.li(vv), .lo());
endmodule

module g4_view35 ();
  logic a;
  logic [63:0] b0, b1;
  g4sub35 #()          u_def (.a_i(a), .b_o(b0));
  g4sub35 #(.NU(9))    u_ov  (.a_i(a), .b_o(b1));
endmodule
