// r11u35 g1_site35 — WHICH HOLDER's TYPEDEF keeps its range bounds symbolic.
// One written bound family (`NU-1`, bare `NU`, a literal) at every typedef
// holder a range can sit in, plus the signals that reference each typedef so
// both the DEF and the ELAB views of every object are on the grid.
package g1pk35;
  parameter int unsigned PU = 5;
  // A PACKAGE typedef (CompilePackage compiles the body twice; the second
  // pass is Reduce::Yes).
  typedef logic [PU-1:0] pk_vec_t;
  typedef logic [PU:0]   pk_bare_t;
  typedef struct packed { logic [PU-1:0] a; } pk_str_t;
  typedef logic [PU-1:0][1:0] pk_mem_t [2];
endpackage

// A $unit-scope typedef (compiled before any module).
parameter int unsigned GU = 7;
typedef logic [GU-1:0] u_vec_t;

interface g1if35 #(parameter int unsigned IU = 6) ();
  typedef logic [IU-1:0] if_vec_t;
  typedef struct packed { logic [IU-1:0] a; } if_str_t;
  if_vec_t if_v;
  if_str_t if_s;
endinterface

module g1sub35 #(parameter int unsigned NU = 5) ();
  // MODULE-BODY typedefs — CompileModule.cpp:653 passes Reduce::No.
  typedef logic [NU-1:0]        b_op_t;     // an OPERATION bound
  typedef logic [NU:0]          b_bare_t;   // a BARE NAME bound
  typedef logic [7:0]           b_lit_t;    // a LITERAL bound (control)
  typedef logic [NU-1:0][1:0]   b_2d_t;     // two packed dims
  typedef logic [NU-1:0]        b_mem_t [2];       // + a LITERAL unpacked dim
  typedef logic [NU-1:0]        b_umem_t [NU];     // + a SYMBOLIC unpacked dim
  typedef struct packed { logic [NU-1:0] a; } b_str_t;   // the landed control
  typedef logic signed [NU-1:0] b_sgn_t;
  typedef bit [NU-1:0]          b_bit_t;

  b_op_t   v_op;
  b_bare_t v_bare;
  b_lit_t  v_lit;
  b_2d_t   v_2d;
  b_mem_t  v_mem;
  b_umem_t v_umem;
  b_str_t  v_str;
  b_sgn_t  v_sgn;
  b_bit_t  v_bit;

  // The package / $unit twins, referenced so their listings materialise.
  g1pk35::pk_vec_t  p_v;
  g1pk35::pk_bare_t p_b;
  g1pk35::pk_str_t  p_s;
  g1pk35::pk_mem_t  p_m;
  u_vec_t           u_v;

  // A GEN-SCOPE typedef.
  if (NU > 0) begin : g_blk
    typedef logic [NU-1:0] g_vec_t;
    g_vec_t g_v;
  end

  // A FUNCTION-local typedef.
  function automatic int unsigned f35(input int unsigned q);
    typedef logic [NU-1:0] f_vec_t;
    f_vec_t fv;
    fv = q[NU-1:0];
    return fv;
  endfunction
  localparam int unsigned FR = f35(3);
endmodule

module g1_site35 ();
  g1sub35 #() u_def ();           // NOT overridden
  g1sub35 #(.NU(9)) u_ov ();      // overridden
  g1if35 #() u_if ();
endmodule
