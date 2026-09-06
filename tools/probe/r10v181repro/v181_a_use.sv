// r10v181 (ADVERSARIAL VERIFIER of r10uvm181) arm A -- THE USE-SITE axis.
//
// The implementer's arm A varied the ARRAY KIND and read the loop variable in
// three positions.  This arm holds the array kind fixed and varies HOW the
// name is used, because `bind9` is a name lookup that runs over EVERY
// `ref_obj`/`ref_var`/`bit_select` in the arena: an rvalue read, a select
// index, an ARGUMENT passed by value, an argument bound to an OUTPUT formal, a
// case selector, a concat element, a replication count, a `for` header, a
// stream expression and a system-function argument all reach it, and the
// pristine binary reached NONE of them in an EMPTYTF clone body.
//
// Every face appears twice: once in an EMPTYTF body (`no own declarations at
// the subroutine's own level`) and once in a HASLOCALS twin whose cells the
// law must leave exactly where they were.
package thurible_home;

  int    censer_fixed [6];
  int    censer_sink;

  function automatic void ampulla_take(input int wick, output int soot);
    soot = wick + 1;
  endfunction

  function automatic int ampulla_give(input int wick);
    return wick * 3;
  endfunction

  // ---------- EMPTYTF: nothing declared at the function's own level ---------
  function automatic void nave181_empty();
    foreach (censer_fixed[chancel]) begin
      int  transept;
      int  narthex;
      int  clerestory [4];
      // 1. plain rvalue read
      transept = chancel;
      // 2. select index
      transept = censer_fixed[chancel];
      // 3. index of a BLOCK-LOCAL array
      transept = clerestory[chancel];
      // 4. passed by value to a function
      transept = ampulla_give(chancel);
      // 5. bound to an OUTPUT formal (the argument is the block local)
      ampulla_take(chancel, narthex);
      // 6. case selector
      case (chancel)
        0: transept = 1;
        default: transept = 2;
      endcase
      // 7. concat element and replication count
      transept = int'({chancel[1:0], chancel[1:0]});
      // 8. a `for` header bound (read only)
      for (int apse = 0; apse < chancel; apse++)
        transept = transept + apse;
      // 9. system-task / system-function argument.  NOT `$bits(chancel)`:
      //    Surelog's UHDM elaborator SEGFAULTS (rc=139) on `$bits` of a
      //    foreach loop variable, so that face has no golden at all and is
      //    recorded as a golden-side limitation, not a face of this law.
      $display("%0d", chancel);
      transept = transept + $signed(chancel);
      // 10. ternary condition
      transept = (chancel > 2) ? transept : narthex;
      censer_sink = transept;
    end
  endfunction

  // ---------- HASLOCALS twin: one function-scope local, same body ----------
  function automatic void nave181_haslocal();
    int reredos;
    foreach (censer_fixed[chancel]) begin
      int  transept;
      int  narthex;
      int  clerestory [4];
      transept = chancel;
      transept = censer_fixed[chancel];
      transept = clerestory[chancel];
      transept = ampulla_give(chancel);
      ampulla_take(chancel, narthex);
      case (chancel)
        0: transept = 1;
        default: transept = 2;
      endcase
      transept = int'({chancel[1:0], chancel[1:0]});
      for (int apse = 0; apse < chancel; apse++)
        transept = transept + apse;
      $display("%0d", chancel);
      transept = transept + $signed(chancel);
      transept = (chancel > 2) ? transept : narthex;
      reredos = transept;
      censer_sink = reredos;
    end
  endfunction

  // ---------- EMPTYTF task: the same faces in a TASK, not a function -------
  task automatic nave181_task();
    foreach (censer_fixed[chancel]) begin
      int transept;
      transept = ampulla_give(chancel) + censer_fixed[chancel];
      censer_sink = transept;
    end
  endtask

endpackage

package thurible_imp;
  import thurible_home::*;
  int thurible_anchor;
endpackage

module thurible_top;
  initial thurible_imp::thurible_anchor = 0;
endmodule
