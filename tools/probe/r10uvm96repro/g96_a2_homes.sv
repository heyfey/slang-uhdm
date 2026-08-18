// r10uvm96 arm 2 — THE SAME CAST IN EVERY HOME AND EVERY CARRIER.
// `real'(x)` is written once per (home, carrier) pair.  If the kind were a
// property of the home or of the carrier rather than of the keyword, this arm
// would split; it does not.  The class-in-package cell is the HEAD's own shape
// (uvm_pkg::uvm_tlm_time::to_m_res, a `local function real` returning
// `t/real'(scaled) * (secs/m_res)`).
package g96_p2;
  class g96_c2;
    local real m_res;
    // the head's shape, verbatim in structure
    local function real to_m_res(real t, time scaled, real secs);
      return t/real'(scaled) * (secs/m_res);
    endfunction
    function real via_assign(time scaled);
      real z;
      z = real'(scaled);            // assignment RHS
      return z;
    endfunction
    function real via_operand(time scaled);
      return real'(scaled) + 1.0;   // operation operand
    endfunction
    function real via_callarg(time scaled);
      return to_m_res(real'(scaled), scaled, 1.0);   // call argument
    endfunction
    function int via_cond(time scaled);
      if (real'(scaled) > 0.0) return 1; else return 0;   // condition
    endfunction
  endclass
  function automatic real g96_pkgfn(time scaled);
    return real'(scaled);           // package function, return
  endfunction
endpackage
module g96_a2;
  import g96_p2::*;
  time  t0;
  real  r0;
  int   n0;
  function automatic real g96_modfn(time scaled);
    return real'(scaled);           // module function, return
  endfunction
  task automatic g96_modtask(time scaled);
    r0 = real'(scaled);             // module task, assignment
  endtask
  initial begin
    r0 = real'(t0);                 // initial, assignment
    $display(real'(t0));            // initial, call argument
    n0 = (real'(t0) > 0.0) ? 1 : 0; // initial, condition of a ternary
  end
  always_comb r0 = real'(t0);       // always_comb, assignment
endmodule
