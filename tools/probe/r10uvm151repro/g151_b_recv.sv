// r10uvm151 arm B — RECEIVER SHAPES.  Which written receiver forces Surelog's
// `subroutine_call` onto its `select DOT method_call_body` road, and which
// keeps the `(constant_bit_select DOT identifier)*` road.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package pkB151;
  class itB151;
    int offset;
    int inner[$];
  endclass
  class holdB151;
    int    q_queue[$];       // queue
    int    q_dyn[];          // dynamic array
    int    q_assoc[string];  // associative
    int    q_fixed[4];       // fixed unpacked
    itB151 h;                // class handle whose property is a queue
    holdB151 nxt;
    function itB151 mk151(); mk151 = null; endfunction
    task bodyB151;
      int r;
      itB151 loc_h;
      int    loc_q[$];
      itB151 harr[4];
      int    qarr[4][$];
      // ---- SINGLE-COMPONENT receivers (THE LAW) ----
      q_queue.sort() with ( item );        // class property, queue
      q_dyn.sort()   with ( item );        // class property, dynamic
      q_fixed.sort() with ( item );        // class property, fixed
      q_assoc.find_index() with ( item );  // class property, associative
      loc_q.sort()   with ( item );        // subroutine BODY LOCAL
      qarr[2].sort() with ( item );        // INDEXED single component
      // ---- MULTI-COMPONENT receivers (the fence: FIRST road) ----
      h.inner.sort()       with ( item );  // obj . field
      harr[1].inner.sort() with ( item );  // indexed obj . field
      nxt.h.inner.sort()   with ( item );  // three names
      loc_h.inner.sort()   with ( item );  // local obj . field
      // ---- `this.`-rooted receiver (the fence: THIRD road) ----
      this.q_queue.sort() with ( item );
      // ---- the same receivers WITHOUT a with clause (the fence) ----
      q_queue.sort();
      q_dyn.reverse();
      q_fixed.reverse();
      loc_q.shuffle();
      qarr[2].shuffle();
      h.inner.sort();
      harr[1].inner.reverse();
      nxt.h.inner.shuffle();
      this.q_queue.reverse();
      r = 0;
    endtask
  endclass
endpackage
