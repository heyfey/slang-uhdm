// V9 — the RF-1 DISTINGUISHER put under load: a METHOD-LOCAL receiver (the
// bit_conv shape) vs a CLASS-PROPERTY receiver (the head's arb_sequence_q
// shape), side by side in ONE class, each with a NON-CONSTANT bound.
package v9_pkg;
  class c9;
    int unsigned prop_q[$];        // CLASS PROPERTY  (head shape)
    logic [31:0] prop_v;
    function automatic int on_prop(int b);
      int unsigned t[$];
      t = prop_q[0:b-1];
      return t.size();
    endfunction
    function automatic int on_local(int b);
      int unsigned loc_q[$];       // METHOD LOCAL    (bit_conv shape)
      int unsigned t[$];
      loc_q.push_back(1); loc_q.push_back(2); loc_q.push_back(3);
      t = loc_q[0:b-1];
      return t.size();
    endfunction
    function automatic logic [7:0] li(int b);
      logic [31:0] loc_v;
      loc_v = 32'hdead_beef;
      return loc_v[b +: 8];        // METHOD-LOCAL packed, indexed, var base
    endfunction
    function automatic logic [7:0] pi(int b);
      return prop_v[b -: 8];       // CLASS-PROPERTY packed, indexed-down
    endfunction
  endclass
endpackage
module v9_local;
  v9_pkg::c9 h;
  int a0, a1; logic [7:0] a2, a3;
  initial begin
    h = new();
    a0 = h.on_prop(2); a1 = h.on_local(2); a2 = h.li(3); a3 = h.pi(15);
  end
endmodule
