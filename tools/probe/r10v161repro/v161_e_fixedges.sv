// r10v161 ARM E — THE EDGES OF THE TWO VERIFIER TERMS.  Every shape that could
// make § castOperandNeverBindsInWindow161v suppress a bind golden MAKES, or
// let one through, and every shape that could make the extended
// § namedBlkLocalNoBind144v over- or under-reach.  MEASUREMENT ONLY.
// LHS golden (Surelog), RHS ours.
package pk_e161;
  parameter int PK_E = 4;
  typedef enum bit [1:0] {EE0, EE1} ee_t;
endpackage

class Edge_e161;
  int prop = 1;
  int aprop[4];

  function int helper(int z); return z; endfunction

  // ---- FIX 1 edges: the cast in every nesting -------------------------
  function void e_cast_nest(int formal_e);
    int loc = 1;
    bit [3:0] nib = 0;
    logic [7:0] byt = 0;
    assert (helper(int'(loc)) == 1);                  // e01 cast inside a CALL arg
    assert (int'(helper(loc)) == 1);                  // e02 a CALL inside a cast
    assert (int'(4'(loc)) == 1);                      // e03 cast inside a cast
    assert (int'(loc + formal_e) == 1);               // e04 an OPERATION under a cast
    assert (int'({nib, nib}) == 0);                   // e05 a CONCAT under a cast
    assert (int'({2{nib}}) == 0);                     // e06 a REPLICATION under a cast
    assert (int'(aprop[loc]) == 0);                   // e07 a property SELECT under a cast
    assert (int'(byt[loc]) == 0);                     // e08 a local's BIT SELECT under a cast
    assert (aprop[int'(loc)] == 0);                   // e09 a cast as an INDEX
    assert (loc inside {int'(formal_e)});             // e10 a cast inside `inside`
    assert ((loc > 0) ? int'(loc) == 1 : 1'b1);       // e11 a cast in a ternary arm
    assert ($signed(loc) == 1);                       // e12 $signed as a SYSTEM CALL
    assert ($unsigned(loc) == 1);                     // e13 $unsigned as a SYSTEM CALL
    assert ($bits(int'(loc)) == 32);                  // e14 a cast inside $bits
    assert (signed'(loc) == 1);                       // e15 the signedness CAST
    assert (pk_e161::ee_t'(nib) == pk_e161::EE0);     // e16 an enum type cast
    assert (int'(pk_e161::PK_E) == 4);                // e17 a PARAMETER under a cast
    assert (int'(prop) == 1);                         // e18 a PROPERTY under a cast
    // the un-cast controls at the same depth, which must KEEP binding
    assert (loc == 1);                                // e19
    assert (formal_e == 1);                           // e20
    assert (helper(loc) == 1);                        // e21
    assert (byt[loc] == 0);                           // e22
    assert ({nib, nib} == 0);                         // e23
    assert ($bits(loc) == 32);                        // e24
  endfunction

  // ---- FIX 2 edges: the named block in every nesting ------------------
  function void e_named_nest();
    int fn_loc = 1;                                   // declared in the FUNCTION
    begin : nb1
      int nb1_loc = 1;                                // declared in a NAMED block
      begin                                           // an UNNAMED block inside it
        int un_loc = 1;                               // declared in the UNNAMED block
        assert (nb1_loc == 1);                        // e30 named-block local  -> bare
        assert (un_loc == 1);                         // e31 unnamed-block local -> binds
        assert (fn_loc == 1);                         // e32 function local      -> binds
      end
    end
    begin                                             // an UNNAMED block first
      int un2_loc = 1;
      begin : nb2
        int nb2_loc = 1;
        assert (nb2_loc == 1);                        // e33 named local   -> bare
        assert (un2_loc == 1);                        // e34 unnamed local -> binds
        assert (fn_loc == 1);                         // e35 function local -> binds
      end
    end
  endfunction

  task e_named_task();
    int t_loc = 1;
    begin : nb3
      int nb3_loc = 1;
      assert (nb3_loc == 1);                          // e36 in a TASK
      assert (t_loc == 1);                            // e37
    end
  endtask

  static function int e_named_static(int f_st);
    int s_loc = 1;
    begin : nb4
      int nb4_loc = 1;
      assert (nb4_loc == 1);                          // e38 in a STATIC method
      assert (s_loc == 1);                            // e39
      assert (f_st == 1);                             // e40 its formal
    end
    return s_loc;
  endfunction

  function new();
    int c_loc = 1;
    begin : nb5
      int nb5_loc = 1;
      assert (nb5_loc == 1);                          // e41 in a CONSTRUCTOR
      assert (c_loc == 1);                            // e42
    end
  endfunction

  function void e_named_case();
    int cl = 1;
    begin : nb6
      int nb6_loc = 2;
      case (cl)
        nb6_loc: cl = 1;                              // e43 named local, case ITEM
        cl:      cl = 2;                              // e44 function local, case ITEM
        default: cl = 0;
      endcase
    end
  endfunction

  // a named block inside a CONTROL BODY — § 28 already silences it, and the
  // term must not change that
  function void e_named_deep();
    int dl = 1;
    if (prop > 0) begin : nb7
      int nb7_loc = 1;
      assert (nb7_loc == 1);                          // e45
      assert (dl == 1);                               // e46
    end
  endfunction
endclass

class GenE161 #(type T = int, int W = 1);
  T gp;
  function void e_gen(T formal_g);
    T loc;
    begin : gnb
      T gnb_loc;
      assert (gnb_loc != gp);                         // e50 named local, generic class
      assert (loc != gp);                             // e51 function local
      assert (int'(W) != 0);                          // e52 a cast of a parameter
    end
  endfunction
endclass

module top_e161;
  Edge_e161 ee;
  GenE161 #(int, 1) ge1;
  GenE161 #(bit, 2) ge2;
  GenE161 #() ge0;
  int mv = 1;

  // the MODULE-function control the first cut of FIX 1 got wrong
  function automatic int mod_fn_e(int q);
    int loc = 1;
    assert (int'(loc) == 1);                          // e60 golden BINDS
    assert (loc == 1);                                // e61 golden BINDS
    begin : mnb
      int mnb_loc = 1;
      assert (mnb_loc == 1);                          // e62 named block, module fn
    end
    return q;
  endfunction

  initial begin
    ee = new();
    mv = mod_fn_e(1);
  end
endmodule
