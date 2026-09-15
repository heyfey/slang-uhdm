// v11u42 arm v7 — WHERE the reference SITS: inside the declaring package,
// inside another package, inside a class, inside a module.
package pa7;
  localparam int unsigned LP = 8;
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
  function automatic logic f_own(s_t a);
    return a.m[LP-1];                 // c01 own pkg param, UNQUALIFIED, in pkg fn
  endfunction
  function automatic logic f_ownq(s_t a);
    return a.m[pa7::LP-1];            // c02 own pkg param, QUALIFIED, in pkg fn
  endfunction
  task automatic t_own(s_t a, output logic r);
    r = a.m[LP-2];                    // c03 own pkg param in a pkg TASK
  endtask
  class c7;
    function automatic logic mf(s_t a);
      return a.m[LP-3];               // c04 own pkg param in a pkg CLASS method
    endfunction
  endclass
endpackage

package pb7;
  import pa7::*;
  localparam int unsigned OWN = 5;
  function automatic logic f_cross(pa7::s_t a);
    return a.m[pa7::LP-1];            // c05 OTHER pkg's param, in a pkg fn
  endfunction
  function automatic logic f_selfb(pa7::s_t a);
    return a.m[OWN-1];                // c06 own pkg param (pb7), in pb7's fn
  endfunction
endpackage

module v7 (input logic [19:0] w20, output logic [63:0] o);
  pa7::s_t v;
  assign v = w20;
  function automatic logic f_mod(pa7::s_t a);
    return a.m[pa7::LP-1];            // c07 pkg param in a MODULE function
  endfunction
  assign o[0] = pa7::f_own(v);
  assign o[1] = pa7::f_ownq(v);
  assign o[2] = pb7::f_cross(v);
  assign o[3] = pb7::f_selfb(v);
  assign o[4] = f_mod(v);
  logic tr;
  always_comb pa7::t_own(v, tr);
  assign o[5] = tr;
  assign o[6] = v.m[pa7::LP-1];       // c08 module-level control
endmodule
