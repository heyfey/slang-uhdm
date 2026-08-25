// r10uvm137 arm E — MULTIPLICITY.  One parameterised module carrying the law's
// shape, instantiated ONCE, TWICE and THREE times, plus a package class used
// from every instance: the multiset join must keep the copies apart and the
// law must answer identically in each.  MEASUREMENT ONLY.
package anvil137;
  typedef class Rivet137;
  class Rivet137;
    bit lugs137[Rivet137];
    string tags137[int];
  endclass
  class Press137;
    extern function int stamp137(ref bit sp_a137[Rivet137],
                                 ref Rivet137 sp_b137[Rivet137]);
  endclass
  function int Press137::stamp137(ref bit sp_a137[Rivet137],
                                  ref Rivet137 sp_b137[Rivet137]);
    int beat137;
    foreach (sp_a137[m1]) foreach (m1.lugs137[m2]) beat137++;
    foreach (sp_a137[m3]) foreach (m3.tags137[m4]) beat137++;
    foreach (sp_b137[m5]) foreach (m5.lugs137[m6]) beat137++;
    return beat137;
  endfunction
endpackage

module clamp137 #(parameter int JAWS137 = 1) (input logic tick137);
  import anvil137::*;
  bit      cl_a137[Rivet137];   // MODULE-LEVEL variable
  Rivet137 cl_b137[Rivet137];
  int      beat137;
  Press137 tool137;
  initial begin
    tool137 = new();
    beat137 = tool137.stamp137(cl_a137, cl_b137);
  end
  always @(posedge tick137) begin
    foreach (cl_a137[m7]) foreach (m7.lugs137[m8]) beat137 += JAWS137;
    foreach (cl_b137[m9]) foreach (m9.lugs137[ma]) beat137 += JAWS137;
  end
endmodule


module tope137 (input logic tick137);
  clamp137 #(.JAWS137(1)) one137   (.tick137(tick137));
  clamp137 #(.JAWS137(2)) two137   (.tick137(tick137));
  clamp137 #(.JAWS137(3)) three137 (.tick137(tick137));
endmodule
