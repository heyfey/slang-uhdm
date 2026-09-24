// r10uvm171 arm a1 — THE POSITION x HOME GRID.
// One package free function that touches its own RETURN NAME in every
// position the emitter can build, and a second package that WILDCARD-IMPORTS
// it so Surelog clones the same body into a different home.  The law says the
// clone binds the select and method-receiver positions and the home does not,
// so the SAME six references must read differently in the two packages —
// an arm whose two halves agree would be testing nothing.
package pos_home_171;
  function string sc_shape();
    int kx;
    byte bq;
    if (sc_shape != "") return sc_shape;      // bare read + bare return
    sc_shape = "quartz beam";                 // bare LHS
    kx = sc_shape.len() - 1;                  // METHOD RECEIVER
    bq = sc_shape[kx];                        // BIT_SELECT, rvalue
    sc_shape[0] = bq;                         // BIT_SELECT, lvalue
    sc_shape = sc_shape.substr(0, kx);        // METHOD RECEIVER on the RHS
  endfunction

  // A control in the SAME body family: every position above, but on an
  // ORDINARY LOCAL rather than on the return name.  Nothing here may move.
  function string lc_shape();
    string wv;
    int kx;
    byte bq;
    wv = "onyx";
    kx = wv.len() - 1;
    bq = wv[kx];
    wv[0] = bq;
    lc_shape = wv.substr(0, kx);
  endfunction

  // A PACKED-vector return: the select family other than bit_select.
  function logic [15:0] pv_shape();
    int kx;
    kx = 3;
    pv_shape = 16'hbeef;
    pv_shape[kx] = 1'b1;                      // bit_select on a packed return
    pv_shape[7:4] = 4'h5;                     // PART_SELECT
    pv_shape[kx +: 2] = 2'b10;                // INDEXED_PART_SELECT
  endfunction
endpackage

package pos_clone_171;
  import pos_home_171::*;
  function int use_them();
    string s1 = sc_shape();
    string s2 = lc_shape();
    logic [15:0] v1 = pv_shape();
    return s1.len() + s2.len() + int'(v1[0]);
  endfunction
endpackage

module pos_top_171;
  import pos_clone_171::*;
  int rr;
  initial rr = use_them();
endmodule
