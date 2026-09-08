// r10uvm205 arm C — THE SHARING CONTROL, the `uvm_reg_map::do_bus_read` shape:
// a queue of a package typedef declared at the body's own level and then walked
// by `foreach`, which is where our emitter hands the DECLARATION and the
// foreach REFERENCE VARIABLE one and the same element ref.  Golden keeps the
// home body's cell QUALIFIED, so a ref reached from both must not move.
package p205a_s;
  typedef bit [7:0] bt205;
  function automatic int fsh205(input int n205);
    bt205 addrs205[$];
    int   s205 = 0;
    addrs205.push_back(8'h1);
    foreach (addrs205[i205])
      s205 += int'(addrs205[i205]);
    return s205 + n205;
  endfunction
endpackage

package p205b_s;
  import p205a_s::*;
  function automatic int gs205();
    return fsh205(1);
  endfunction
endpackage

module g205_c_share;
  import p205b_s::*;
  int r205;
  initial r205 = gs205();
endmodule
