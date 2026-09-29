// § ppIdentEndInRebuiltText219 § ppDotNameAfterArgToken219 — a method-call actual spread over three lines with a block comment, forwarded through two multi-line macros
`define INNER(CB,METHOD) \
  begin \
    if (CB != null) \
      CB.METHOD; \
  end
`define OUTER(CB,METHOD) \
  begin \
    `INNER(CB,METHOD) \
  end
package p;
class cb_c;
  function void notify(int a, int b, int c); endfunction
endclass
class user_c;
  cb_c cb;
  function void run(int x);
    `OUTER(cb, notify(x,
                      /* second */ x + 1,
                      3))
  endfunction
endclass
endpackage
module top;
  import p::*;
endmodule
