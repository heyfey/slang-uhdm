// r10v107 arm b8 — a `ref_var` local read from a NAMED BLOCK, a FORK, a
// FOREACH body and a CASE selector in an out-of-body body.  MEASUREMENT ONLY.
// (An UNDECLARED identifier and a MISSPELLED property are SLANG_REJECT — slang
// refuses the source outright — so those two shapes are out of scope by the
// campaign's own definition; measured, not assumed.)
package pb8;

  class d8;
    int fld;
  endclass

  class snk8;
    function int ask(d8 v); return 0; endfunction
    function int askb(int a); return 0; endfunction
  endclass

  class c8 #(type T = d8);
    snk8 s;
    d8   plain;
    int  iq[4];
    extern function void named_blk();
    extern function void fork_blk();
    extern function void foreach_blk();
    extern function int  case_sel();
    extern function void while_blk();
  endclass

  function void c8::named_blk();
    T v;
    begin : nb8
      if (s.ask(v) == 0) begin
      end
    end
  endfunction

  function void c8::fork_blk();
    T v;
    fork
      if (s.ask(v) == 0) begin
      end
    join_none
  endfunction

  function void c8::foreach_blk();
    T v;
    foreach (iq[i8]) begin
      if (s.ask(v) == 0) begin
      end
    end
  endfunction

  function int c8::case_sel();
    T cs8;
    case (s.ask(cs8))
      0: return 1;
      default: return 0;
    endcase
  endfunction

  function void c8::while_blk();
    T v;
    while (s.ask(v) == 0) begin
      s.ask(v);
    end
  endfunction

endpackage

module topb8;
  import pb8::*;
  c8 #(d8) inst;
  initial inst = new();
endmodule
