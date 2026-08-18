// r10vbuvm21repro/v1carrier.sv — ADVERSARIAL CARRIER arm for
// § incDecStmtOperandBinds21.  Every statement wrapper that does NOT raise the
// emitter's ctrlBodyDepth28 (Timed / Wait / ImmediateAssertion / label / fork
// flavours) but DOES interpose a statement node in Surelog's compileStmt — the
// exact shapes the law's "only BLOCK scopes" clause must exclude.
package vp1;
  typedef enum { A1, B1 } ve1;
  class vc1;
    int aa[ve1];
    int p1;
    event ev1;
    // --- carriers that raise NO ctrlBodyDepth28 in our emitter ---
    task c_delay(ve1 s);            #1 aa[s]++;                        endtask
    task c_evctl(ve1 s);            @(ev1) aa[s]++;                    endtask
    task c_wait(ve1 s);             wait (p1) aa[s]++;                 endtask
    function void c_assert(ve1 s);  assert (p1) aa[s]++;               endfunction
    function void c_assert_else(ve1 s); assert (p1) p1++; else aa[s]++; endfunction
    function void c_label(ve1 s);   lbl1: aa[s]++;                     endfunction
    task c_forkjn(ve1 s);           fork aa[s]++; join_none            endtask
    task c_forkja(ve1 s);           fork aa[s]++; join_any             endtask
    task c_forkbeg(ve1 s);          fork begin aa[s]++; end join       endtask
    task c_delaybeg(ve1 s);         begin #1 aa[s]++; end              endtask
    // --- carriers the law already claims / excludes (controls) ---
    function void c_plain(ve1 s);   aa[s]++;                           endfunction
    function void c_beg(ve1 s);     begin aa[s]++; end                 endfunction
    function void c_if(ve1 s);      if (p1) aa[s]++;                   endfunction
    function void c_ifelse(ve1 s);  if (p1) p1++; else aa[s]++;        endfunction
    function void c_uniqif(ve1 s);  unique if (p1) aa[s]++;            endfunction
    function void c_pcase(ve1 s);   priority case (p1) 0: aa[s]++; default: p1++; endcase endfunction
    function void c_two(ve1 s);     aa[s]++; aa[s]++;                  endfunction
    function void c_after_if(ve1 s); if (p1) p1++; aa[s]++;            endfunction
  endclass
endpackage
