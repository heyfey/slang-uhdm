// r10svs2 VERIFIER ARM w2 — WHITESPACE BETWEEN THE RECEIVER AND THE METHOD NAME.
// § parensLessCallIsPathRefObj rebuilds the span from
// `mStart9 = recv->sourceRange.end() + 1`, which assumes EXACTLY ONE character
// (the `.`) sits between the receiver's last token and the method name.  Legal
// SystemVerilog allows any trivia there -- spaces, a newline, a comment -- and
// every one of them shifts the method token further right.  This arm puts the
// tight form and the spaced forms side by side so the location can be read off.
class sd;
  int d[];
  int q[$];

  function int f();
    int r;
    r = d.size;          // (1) TIGHT: the shape every implementer arm used
    r = r + d . size;    // (2) ONE SPACE either side of the dot
    r = r + q .size;     // (3) space BEFORE the dot only
    r = r + q. size;     // (4) space AFTER the dot only
    r = r + d /* c */ . size;  // (5) a COMMENT between receiver and dot
    r = r + d
            .size;       // (6) a NEWLINE before the dot
    return r;
  endfunction
endclass

module top;
  sd o;
  initial begin
    o = new();
    $display("%0d", o.f());
  end
endmodule
