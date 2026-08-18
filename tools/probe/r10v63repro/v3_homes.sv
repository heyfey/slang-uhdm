// r10v63 — V3: DECLARATION HOME grid.  port-list / body / gen-if / gen-for /
// gen-case / nested gen / package / interface / $unit(compilation-unit) /
// class, each with the head's ternary body and a `-`-body, on an `int` and a
// `logic [15:0]` target.  Also OVERRIDE state (defaulted vs overridden
// parameter-port) and 1..3 instances.
// MEASUREMENT ONLY.
function automatic integer vb(integer value);
  return (value == 1) ? 1 : $clog2(value);
endfunction
function automatic integer sb(integer value);
  return value - 1;
endfunction

package pk63;
  function automatic integer pvb(integer value);
    return (value == 1) ? 1 : $clog2(value);
  endfunction
  function automatic integer psb(integer value);
    return value - 1;
  endfunction
  localparam int          pk_tern = pvb(16384);
  localparam int          pk_sub  = psb(300);
  localparam logic [15:0] pk_vt   = pvb(16384);
endpackage

interface if63 #(parameter int W = 16384) ();
  localparam int          if_tern = vb(W);
  localparam int          if_sub  = sb(W);
  localparam logic [15:0] if_vt   = vb(W);
  logic x;
endinterface

localparam int cu_tern = vb(16384);   // $unit
localparam int cu_sub  = sb(300);

module s_home #(
  parameter  int          Depth   = 512,
  localparam int          pp_tern = vb(Depth),
  localparam logic [15:0] pp_vt   = vb(Depth),
  localparam int          pp_sub  = sb(Depth)
) (output logic o);
  localparam int          bd_tern = vb(Depth);
  localparam logic [15:0] bd_vt   = vb(Depth);
  localparam int          bd_sub  = sb(Depth);
  if (Depth > 2) begin : g_if
    localparam int          gi_tern = vb(Depth);
    localparam logic [15:0] gi_vt   = vb(Depth);
    localparam int          gi_sub  = sb(Depth);
    if (Depth > 4) begin : g_if2
      localparam int gi2_tern = vb(Depth);
    end
  end
  for (genvar gg = 0; gg < 2; gg++) begin : g_for
    localparam int          gf_tern = vb(Depth + gg);
    localparam logic [15:0] gf_vt   = vb(Depth + gg);
  end
  case (Depth)
    16384: begin : g_case
      localparam int gc_tern = vb(Depth);
    end
    default: begin : g_case
      localparam int gc_tern = vb(Depth + 1);
    end
  endcase
  assign o = |{pp_tern[0],pp_vt[0],pp_sub[0],bd_tern[0],bd_vt[0],bd_sub[0],
               pk63::pk_tern[0],cu_tern[0],cu_sub[0]};
endmodule

module top(output logic o1, output logic o2, output logic o3);
  s_home              u1 (.o(o1));         // DEFAULTED (not overridden)
  s_home #(.Depth(16384)) u2 (.o(o2));     // OVERRIDDEN
  s_home #(.Depth(1))     u3 (.o(o3));     // OVERRIDDEN, ternary takes branch 1
  if63  #(.W(16384)) u_if ();
endmodule
