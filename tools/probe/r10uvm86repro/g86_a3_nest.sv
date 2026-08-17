// r10uvm86 arm a3 — the NESTING LADDER.  Only a return that is a DIRECT
// statement of the body reaches Surelog's inherited Reduce::Yes; every nested
// construct hardcodes Reduce::No.  One class, one package, both spellings.
package p3;
  class n3;
    int g;
    extern function int d_only();      // sole statement of the body
    extern function int d_multi(int x);// direct member of the synthetic begin
    extern function int d_beginend();  // EXPLICIT begin/end closes the window
    extern function int d_if(int x);
    extern function int d_ifbegin(int x);
    extern function int d_for();
    extern function int d_while();
    extern function int d_case(int x);
    extern function int d_do();
    extern function int d_nblk();
    extern function int i_only();      // in-body twin of d_only
    function int b_only(); return -1; endfunction
  endclass
  function int n3::d_only(); return -1; endfunction
  function int n3::d_multi(int x);
    g = x;
    return -1;
  endfunction
  function int n3::d_beginend();
    begin
      return -1;
    end
  endfunction
  function int n3::d_if(int x);
    if (x) return -1;
    return 0;
  endfunction
  function int n3::d_ifbegin(int x);
    if (x) begin
      return -1;
    end
    return 0;
  endfunction
  function int n3::d_for();
    for (int i = 0; i < 2; i++) return -1;
    return 0;
  endfunction
  function int n3::d_while();
    while (g) return -1;
    return 0;
  endfunction
  function int n3::d_case(int x);
    case (x)
      0: return -1;
      default: return 0;
    endcase
  endfunction
  function int n3::d_do();
    do return -1; while (0);
    return 0;
  endfunction
  function int n3::d_nblk();
    nb3: begin
      return -1;
    end
  endfunction
  function int n3::i_only(); return -1; endfunction
  function int pf_only(); return -1; endfunction
  function int pf_beginend(); begin return -1; end endfunction
  function int pf_if(int x); if (x) return -1; return 0; endfunction
  int g3;
  task pt_body(); g3 = -1; endtask
endpackage
