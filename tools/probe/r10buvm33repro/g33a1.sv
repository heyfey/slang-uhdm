// r10buvm33repro/g33a1.sv — § foreachScopedArrayWrittenClassVar33, THE GRID.
// The UVM shape: a foreach whose array reference is WRITTEN `C::prop`.
// Five qualifier spellings x foreach / indexed read / Lhs / Rhs / argument /
// method receiver, from an OUT-OF-BODY home, an IN-BODY home, a PACKAGE
// FUNCTION home and a MODULE home.  Read cell by cell; MEASUREMENT ONLY.
package p33;

  class other33;
    static int oq33[$];
    static int oa33[4];
  endclass

  class base33;
    static int bq33[$];
  endclass

  class der33 extends base33;
    typedef der33 this_type;              // the UVM `this_type` typedef
    typedef other33 alias33;              // a typedef naming ANOTHER class
    static int dq33[$];
    static int da33[4][3];
    int inst33[$];
    extern function void oob33();
    function void inb33();
      // IN-BODY home
      foreach (this_type::dq33[i])        // B1  scoped, this_type
        dq33.push_back(this_type::dq33[i]);
      foreach (der33::dq33[i])            // B2  scoped, own class name
        dq33.push_back(der33::dq33[i]);
      foreach (alias33::oq33[i])          // B3  scoped, alias to other class
        dq33.push_back(alias33::oq33[i]);
      foreach (other33::oq33[i])          // B4  scoped, another class name
        dq33.push_back(other33::oq33[i]);
      foreach (base33::bq33[i])           // B5  scoped, the BASE class name
        dq33.push_back(base33::bq33[i]);
      foreach (dq33[i])                   // B6  UNQUALIFIED control
        dq33.push_back(dq33[i]);
      foreach (this_type::da33[i,j])       // B7  two-dimensional
        dq33.push_back(this_type::da33[i][j]);
    endfunction
  endclass

  int pv33[$];

  function void pfun33();
    // PACKAGE FUNCTION home
    foreach (der33::dq33[i])              // P1
      pv33.push_back(der33::dq33[i]);
    foreach (p33::pv33[i])                // P2  a PACKAGE qualifier on a pkg var
      pv33.push_back(p33::pv33[i]);
    foreach (pv33[i])                     // P3  UNQUALIFIED control
      pv33.push_back(pv33[i]);
  endfunction

  function void der33::oob33();
    // OUT-OF-BODY home (written at package scope) — the UVM shape exactly
    int r33;
    foreach (this_type::dq33[i])          // A1  THE HEAD SHAPE
      dq33.push_back(this_type::dq33[i]);
    foreach (der33::dq33[i])              // A2  own class name
      dq33.push_back(der33::dq33[i]);
    foreach (alias33::oq33[i])            // A3  alias
      dq33.push_back(alias33::oq33[i]);
    foreach (other33::oq33[i])            // A4  another class
      dq33.push_back(other33::oq33[i]);
    foreach (base33::bq33[i])             // A5  the base class
      dq33.push_back(base33::bq33[i]);
    foreach (dq33[i])                     // A6  UNQUALIFIED control
      dq33.push_back(dq33[i]);
    foreach (inst33[i])                   // A7  a NON-static property
      dq33.push_back(inst33[i]);
    r33 = this_type::dq33[0];             // A8  indexed READ  (Rhs)
    this_type::dq33[0] = r33;             // A9  indexed WRITE (Lhs)
    r33 = other33::oa33[1];               // A10 indexed read, other class
    $display("%0d", this_type::dq33[1]);  // A11 argument position
    dq33.push_back(this_type::dq33[2]);   // A12 method argument
    if (this_type::dq33.size() > 0)       // A13 method call on a scoped ref
      r33 = 1;
  endfunction

endpackage

module top33;
  import p33::*;
  int mq33[$];
  initial begin
    // MODULE home
    foreach (p33::der33::dq33[i])         // M1  THREE-segment scoped name
      mq33.push_back(p33::der33::dq33[i]);
    foreach (p33::pv33[i])                // M2  package qualifier
      mq33.push_back(p33::pv33[i]);
    foreach (mq33[i])                     // M3  UNQUALIFIED control
      mq33.push_back(mq33[i]);
  end
endmodule
