// r10v180 arm A — THE HOME AND THE CLONE IN ONE DESIGN, SAME TYPEDEF, SAME ROLES.
// The single sharpest risk of a link re-point reached by a whole-design walk:
// if our emitter memoises ONE ref_typespec/typespec object for a declaration
// that both the home body and the clone body reach, a clone-gated rebind
// silently makes the HOME bare too — and golden qualifies the home.
// Every role the law can reach appears on BOTH sides: formal, top local,
// nested-block local, deeper-block local, cast operand, call argument,
// a $bits operand and a condition operand.
package quarry_pk;
  typedef logic [9:0]  ledge_ty;
  typedef bit   [4:0]  gully_ty;

  function automatic int unsigned ledge_use(ledge_ty crest);
    ledge_ty basin;
    int unsigned tot;
    basin = crest;
    tot = 0;
    if (basin != 0) begin
      ledge_ty ridge;
      ridge = ledge_ty'(basin - 1);
      for (int q = 0; q < 2; q++) begin
        ledge_ty scarp;
        scarp = ridge;
        tot = tot + $bits(scarp);
        if (scarp == ledge_ty'(0)) tot = tot + 1;
      end
      basin = ridge;
    end
    return tot + int'(basin);
  endfunction

  function automatic int unsigned gully_use(gully_ty crest);
    gully_ty basin;
    basin = crest;
    begin
      gully_ty ridge;
      ridge = gully_ty'(basin);
      basin = ridge;
    end
    return int'(basin) + ledge_use(ledge_ty'(basin));
  endfunction
endpackage

// the wildcard importer: Surelog clones BOTH subroutines into it
package quarry_imp;
  import quarry_pk::*;
endpackage

module quarry_top;
  import quarry_pk::*;
  ledge_ty apex;
  gully_ty vale;
  int unsigned tally;
  initial begin
    apex = 10'h123;
    vale = 5'h07;
    tally = ledge_use(apex) + gully_use(vale);
  end
endmodule
