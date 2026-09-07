// r10v182 arm F — RECEIVER KINDS the implementer's grid does not reach.
// Each cell asks whether OUR `Actual_group` is an array_var/packed_array_var
// where SURELOG's is not (or the reverse).  A mismatch in either direction is
// a divergence the patch's `arrayActual182` gate cannot see.
package plinth182_home;

  typedef struct { int gantry; int wicket; } sconce182_t;

  class newel182;
    int  spandrel [$];
    int  jamb;
    function automatic int f_this182();
      int lug [$];
      lug = spandrel.max;
      return this.spandrel.size + lug.size;   // F_this / F_bare_prop
    endfunction
  endclass

  // packed array receiver — slang REJECTS `.size` on a packed array
  // ("invalid member access for type 'logic[3:0][7:0]'"), so the
  // `packed_array_var` mint arm of `DeepClone` is not reachable from legal
  // source at all.  A packed array INSIDE an unpacked one is the nearest
  // legal neighbour and is measured instead.
  function automatic int f_packed182_fn();
    logic [7:0] corbel [4];
    logic [7:0] bay [$];
    bay = corbel.max;                  // F_pkelem_max
    return bay.size;
  endfunction

  // 2-D unpacked receiver, and a BIT-SELECT predecessor
  function automatic int f_bitsel182_fn();
    int mullion [$][$];
    int hob;
    hob = mullion.size;                // F_2d_size   (plain)
    hob = hob + mullion[0].size;       // F_bitsel_size (bit_select predecessor)
    return hob;
  endfunction

  // an ARRAY OF CLASS receiver
  function automatic int f_clsq182_fn();
    newel182 finial [$];
    int      hob;
    hob = finial.size;                 // F_clsq_size
    return hob;
  endfunction

  // a FORMAL (io_decl) receiver, with a body local of the same name beside it
  function automatic int f_formal182_fn(ref int transom [$]);
    int size;
    size = 7;
    return transom.size + size;        // F_formal_size
  endfunction

  // a STRUCT-VAR receiver whose member is literally named `max`
  typedef struct { int max; int min; } quoin182_t;
  function automatic int f_smax182_fn();
    quoin182_t plinth;
    plinth.max = 1;
    return plinth.max + plinth.min;    // F_structmax / F_structmin
  endfunction

  // a QUEUE OF STRUCT, chained: `<queue>.max.<member>` is NOT legal, but
  // `<queue>[0].gantry` is, and it is the bit_select face on an aggregate.
  function automatic int f_chain182_fn();
    sconce182_t soffit [$];
    int         hob;
    hob = soffit.size;                 // F_strq_size
    hob = hob + soffit[0].gantry;      // F_strq_bitsel_member
    return hob;
  endfunction

endpackage

package plinth182_imp;
  import plinth182_home::*;
  int plinth182_anchor;
endpackage

module plinth182_top;
  initial plinth182_imp::plinth182_anchor = 0;
endmodule
