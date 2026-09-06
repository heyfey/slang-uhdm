// r10v181 arm H -- AN EMPTYTF CLONE BODY WITH NO `foreach` AT ALL.
//
// The whole deferred block in UhdmExporter.cpp is gated on
// `if (!pkgCloneBodyLocals9.empty())`, so before this pass a design whose only
// clone bodies were EMPTYTF ran NONE of it -- not law pkgCloneHierBind9, not
// law pkgCloneLocalRefBind37 and not law pkgCloneMember10.  Every arm that
// exercises the law does so through a foreach; this one has none, which
// leaves law pkgCloneMember10 (the struct-member resolution on a non-base
// hier_path element) as the ONLY law that can fire, with an EMPTY `lm9` map
// underneath it.  If the map's re-enabling over-binds anywhere, it over-binds
// here, with nothing else moving to hide it.
//
// The negatives are the same LAW-PCB pair: a PACKAGE-scope struct type
// resolves, a CLASS-scope one does not.
package trebuchet_home;

  typedef struct packed { logic [3:0] mangonel; logic [3:0] onager; } springald_t;

  springald_t trebuchet_pkgstruct;
  int         trebuchet_sink;

  class ballista_cls;
    typedef struct packed { logic [3:0] perrier; logic [3:0] bricole; } couillard_t;
    couillard_t ballista_clsstruct;
    springald_t ballista_pkgtyped;
    int         ballista_prop;

    extern function int scorpion181_empty();
    extern function int scorpion181_haslocal();
  endclass

  // EMPTYTF: no formals, no function-scope Variables, no foreach anywhere.
  function int ballista_cls::scorpion181_empty();
    begin
      springald_t mantlet;
      couillard_t pavise;
      int         quarrel;
      quarrel  = int'(mantlet.mangonel);                // pkg-scope type: resolves
      quarrel  = quarrel + int'(pavise.perrier);        // class-scope type: bare
      quarrel  = quarrel + int'(trebuchet_pkgstruct.onager);   // pkg var, pkg type
      quarrel  = quarrel + int'(ballista_pkgtyped.mangonel);   // property, pkg type
      quarrel  = quarrel + int'(ballista_clsstruct.bricole);   // property, cls type
      quarrel  = quarrel + ballista_prop + trebuchet_sink;
      scorpion181_empty = quarrel;
    end
  endfunction

  // HASLOCALS twin: identical body, one function-scope local.  Already read
  // golden's answer before this pass and must not move.
  function int ballista_cls::scorpion181_haslocal();
    int espringal;
    begin
      springald_t mantlet;
      couillard_t pavise;
      int         quarrel;
      quarrel  = int'(mantlet.mangonel);
      quarrel  = quarrel + int'(pavise.perrier);
      quarrel  = quarrel + int'(trebuchet_pkgstruct.onager);
      quarrel  = quarrel + int'(ballista_pkgtyped.mangonel);
      quarrel  = quarrel + int'(ballista_clsstruct.bricole);
      quarrel  = quarrel + ballista_prop + trebuchet_sink;
      espringal = quarrel;
      scorpion181_haslocal = espringal;
    end
  endfunction

  // An EMPTYTF FREE function, no class at all, no foreach.
  function automatic int mangon181_empty();
    begin
      springald_t mantlet;
      mangon181_empty = int'(mantlet.onager) +
                        int'(trebuchet_pkgstruct.mangonel) + trebuchet_sink;
    end
  endfunction

endpackage

package trebuchet_imp;
  import trebuchet_home::*;
  int trebuchet_anchor;
endpackage

module trebuchet_top;
  initial trebuchet_imp::trebuchet_anchor = 0;
endmodule
