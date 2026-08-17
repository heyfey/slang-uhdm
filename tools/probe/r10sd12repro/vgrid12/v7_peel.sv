// vsd12 cell v7 — THE PEEL, which is the ONE piece of machinery this pass
// INVENTED (r10sd10's predicate is reused verbatim).  grid12 exercises the peel
// at exactly ONE written dimension over a non-array typedef.  Everything below
// is a peel the grid does not contain:
//
//   m2   TWO written dimensions            -> peel twice
//   mq   fixed OUTER, queue INNER          -> peel two DIFFERENT containers
//   dq   dynamic OUTER, fixed INNER
//   aq   assoc OUTER, queue INNER
//   aa   the typedef IS ITSELF AN ARRAY plus ONE written dimension
//        (`typedef zel7 arr_t[4]; z7::arr_t aa[2];`) -> the peel MUST stop at
//        `arr_t`, and the README's §2 states exactly that
//   ia   the same with an INT array typedef
//   ar   the array typedef with NO extra dimension at all (ndim==0 early-out
//        must fire, and the element must not move)
//
// Every element row has its SCALAR twin where one is expressible, so a row
// whose element and scalar disagree refutes the law as stated.
package pv7;

  class zelv7;
    int q;
  endclass

  class z7;                          // sorts AFTER auser7 -> ClassVar arm
    typedef zelv7 d_t;
    typedef zelv7 arr_t[4];          // a class-nested typedef that IS an array
    typedef int   ia_t[3];
  endclass

  class auser7;
    function void f7();
      z7::d_t   m2[2][3];
      z7::d_t   mq[2][$];
      z7::d_t   dq[][2];
      z7::d_t   aq[int][$];
      z7::d_t   sc;                  // the SCALAR twin of all four
      z7::arr_t aa[2];
      z7::ia_t  ia[2];
      z7::arr_t ar;                  // ndim == 0: the early-out
      z7::ia_t  ir;
      m2[0][0] = null;
    endfunction
  endclass

endpackage

module topv7;
  initial begin
    pv7::auser7 u = new();
    u.f7();
  end
endmodule
