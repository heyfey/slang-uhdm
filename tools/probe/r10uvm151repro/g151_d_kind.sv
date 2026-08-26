// r10uvm151 arm D — THE FOUR KEYWORD ARRAY-METHOD NAMES and THE RANDOMIZE
// FORMS, against their plain-identifier twins.  This is the arm that separates
// "a `with` clause was written" from "the grammar could not spell the method
// token as an identifier", and it is the arm that fences `o.randomize()` and
// `o.randomize(x)` OUT of the law while keeping `o.randomize() with { … }` in.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package pkD151;
  class itD151;
    rand int rv;
    rand int rw;
    int offset;
  endclass
  class holdD151;
    int    iq[$];
    bit    bq[$];
    itD151 obj;
    task bodyD151;
      int r;
      itD151 oarr[4];
      int    qarr[4][$];
      // ---- KEYWORD array-method names, NO with clause (THE LAW) ----
      bq.and();
      bq.or();
      bq.xor();
      iq.unique();
      // ---- the same four WITH a with clause (still THE LAW) ----
      bq.and()  with ( item );
      bq.or()   with ( item );
      bq.xor()  with ( item );
      iq.unique() with ( item );
      // ---- PLAIN-IDENTIFIER twins, no with clause (the fence) ----
      iq.unique_index();
      iq.sum();
      iq.product();
      iq.min();
      iq.max();
      iq.sort();
      iq.rsort();
      iq.reverse();
      iq.shuffle();
      // ---- RANDOMIZE: three forms, only the constraint block is the law ----
      obj.randomize();                    // fence  -> method shape
      obj.randomize(rv);                  // fence  -> method shape
      obj.randomize(rv, rw);              // fence  -> method shape
      obj.randomize() with { rv > 1; };   // LAW    -> bare func_call
      obj.randomize(rv) with { rv > 2; }; // LAW    -> bare func_call
      obj.randomize with { rv > 3; };     // LAW    -> bare func_call, no parens
      oarr[1].randomize();                // fence, INDEXED receiver
      oarr[2].randomize() with { rv > 4; };// LAW,  INDEXED receiver
      // ---- three INSTANCES of one law cell on one name ----
      qarr[0].sort() with ( item );
      qarr[1].sort() with ( item );
      qarr[2].sort() with ( item );
      r = 0;
    endtask
  endclass
endpackage
