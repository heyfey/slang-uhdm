// r10v161 ARM D — THE BREAK ARM.  The two cells arm B and arm C caught going
// AWAY from golden, isolated against their `if`-CONDITION mirrors so the
// question "did this patch CREATE the away, or extend one that was already in
// the `if` column?" is answered by measurement.
//   D1  a CAST in the condition        (arm C c92/c93)
//   D2  an assertion inside a NAMED `begin` (arm B b38)
// MEASUREMENT ONLY.  LHS golden (Surelog), RHS ours.
package pk_d161;
  typedef enum bit [1:0] {ED0, ED1} ed_t;
endpackage

class Cast_d161;
  int prop = 1;

  // ---- D1: the cast, in every window position -------------------------
  function void d_cast(int formal_d);
    int loc = 1;
    bit [3:0] nib = 0;
    // the `if` COLUMN — the window our emitter already opens
    if (int'(loc) == 1) prop = 1;                    // d01 cast of a LOCAL
    if (int'(formal_d) == 1) prop = 1;               // d02 cast of a FORMAL
    if (loc == 1) prop = 1;                          // d03 NO cast, local (control)
    if (formal_d == 1) prop = 1;                     // d04 NO cast, formal (control)
    if (bit'(loc)) prop = 1;                         // d05 bit' cast
    if (unsigned'(loc) == 1) prop = 1;               // d06 signedness cast
    if (4'(loc) == 1) prop = 1;                      // d07 SIZE cast
    if (pk_d161::ed_t'(nib) == pk_d161::ED0) prop = 1; // d08 enum type cast
    // the ASSERT COLUMN — the position this pass adds
    assert (int'(loc) == 1);                         // d11 cast of a LOCAL
    assert (int'(formal_d) == 1);                    // d12 cast of a FORMAL
    assert (loc == 1);                               // d13 NO cast, local (control)
    assert (formal_d == 1);                          // d14 NO cast, formal (control)
    assert (bit'(loc));                              // d15
    assert (unsigned'(loc) == 1);                    // d16
    assert (4'(loc) == 1);                           // d17
    assert (pk_d161::ed_t'(nib) == pk_d161::ED0);    // d18
    // the CASE CONDITION column — also an existing window
    case (int'(loc))                                 // d21 cast in a case CONDITION
      1: prop = 1;
      default: prop = 0;
    endcase
    case (loc)
      int'(formal_d): prop = 1;                      // d22 cast in a case ITEM
      loc:            prop = 2;                      // d23 no cast (control)
      default:        prop = 0;
    endcase
  endfunction

  // ---- D2: the named begin -------------------------------------------
  function void d_named_local();
    begin : blk_a
      static int s_a = 5;                            // declared IN the named block
      if (s_a == 5) prop = 1;                        // d31 if column
      assert (s_a == 5);                             // d32 assert column
    end
  endfunction

  function void d_named_outer();
    int outer = 5;                                   // declared in the FUNCTION
    begin : blk_b
      if (outer == 5) prop = 1;                      // d33 if column
      assert (outer == 5);                           // d34 assert column
    end
  endfunction

  function void d_plain_local();
    begin
      static int s_c = 5;                            // plain (unnamed) block
      if (s_c == 5) prop = 1;                        // d35 if column
      assert (s_c == 5);                             // d36 assert column
    end
  endfunction

  function void d_plain_outer();
    int outer2 = 5;
    begin
      if (outer2 == 5) prop = 1;                     // d37 if column
      assert (outer2 == 5);                          // d38 assert column
    end
  endfunction

  function void d_named_nested();
    begin : blk_d
      int mid = 5;
      begin : blk_e
        int inner = 5;
        assert (inner == 5);                         // d39 innermost named
        assert (mid == 5);                           // d40 outer named block's local
      end
    end
  endfunction

  task d_fork_named();
    fork
      begin : blk_f
        static int s_f = 5;
        if (s_f == 5) prop = 1;                      // d41 if column
        assert (s_f == 5);                           // d42 assert column
      end
    join_none
  endtask

  function void d_named_case();
    begin : blk_g
      int gloc = 5;
      case (prop)
        gloc: prop = 1;                              // d43 case ITEM in a named block
        default: prop = 0;
      endcase
    end
  endfunction

  function void d_func_level();
    int flev = 5;
    if (flev == 5) prop = 1;                         // d44 if column, no block
    assert (flev == 5);                              // d45 assert column, no block
  endfunction
endclass

// The SAME two shapes in an OUT-OF-BODY method, where `classMethodNoBind` is
// never set at all — the pristine binary already binds here, so these cells
// isolate the CAST rule from the window rule.
class Oob_d161;
  int prop = 1;
  extern function void d_oob(int formal_o);
endclass

function void Oob_d161::d_oob(int formal_o);
  int loc = 1;
  if (int'(loc) == 1) prop = 1;                      // d51 oob, if + cast
  assert (int'(loc) == 1);                           // d52 oob, assert + cast
  assert (loc == 1);                                 // d53 oob, assert, no cast
  begin : oblk
    static int s_o = 5;
    assert (s_o == 5);                               // d54 oob, named block
  end
endfunction

module top_d161;
  Cast_d161 cd;
  Oob_d161 od;
  int mv = 1;

  function automatic int mod_fn_d(int q);
    int loc = 1;
    if (int'(loc) == 1) return 1;                    // d61 module fn, if + cast
    assert (int'(loc) == 1);                         // d62 module fn, assert + cast
    begin : mblk
      static int s_m = 5;
      assert (s_m == 5);                             // d63 module fn, named block
    end
    return q;
  endfunction

  initial begin
    cd = new();
    od = new();
    mv = mod_fn_d(1);
  end
endmodule
