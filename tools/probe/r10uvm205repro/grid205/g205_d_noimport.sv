// r10uvm205 arm D — THE CONTROL.  The same declarations with NO wildcard
// import anywhere: an EXPLICIT single-name import, which § 16's registry
// (WILDCARD clones only) must never see.  Both binaries must be BYTE-IDENTICAL.
package p205a_n;
  typedef bit [7:0] bt205;
  function automatic int fn205(input bt205 nio205[]);
    bt205 nloc205[];
    return nio205.size() + nloc205.size();
  endfunction
endpackage

package p205b_n;
  import p205a_n::fn205;
  import p205a_n::bt205;
  function automatic int gn205();
    bt205 q205[];
    return fn205(q205);
  endfunction
endpackage

module g205_d_noimport;
  import p205b_n::*;
  int r205;
  initial r205 = gn205();
endmodule
