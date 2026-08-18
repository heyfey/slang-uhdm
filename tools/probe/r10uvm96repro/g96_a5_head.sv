// r10uvm96 arm 5 — THE HEAD, MINIMISED.  uvm-1.2 tlm2/uvm_tlm2_time.svh:87
// and :104 are the only two `real'(...)` casts in either corpus; this is their
// shape with nothing else in the file: a PACKAGE CLASS with a `local function
// real` whose RETURN expression divides by `real'(scaled)`, and a public
// function that multiplies by it.  Pristine mints logic_typespec at both;
// golden mints real_typespec.
package g96_p5;
  class g96_tlm_time;
    local real m_res = 1.0e-12;
    real m_time;
    local function real to_m_res(real t, time scaled, real secs);
      return t/real'(scaled) * (secs/m_res);
    endfunction
    function real get_realtime(time scaled, real secs = 1.0e-9);
      return m_time*real'(scaled) * m_res/secs;
    endfunction
  endclass
endpackage
module g96_a5;
  import g96_p5::*;
  g96_tlm_time h;
  initial h = new();
endmodule
