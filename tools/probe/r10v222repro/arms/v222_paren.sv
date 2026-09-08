// r10v222 — ADVERSARIAL ARM P: a '(' that belongs to the RECEIVER, not to the
// argument list.  The patched read cuts the raw statement at the FIRST '(' and
// takes the last '.' of what remains; every cell below writes a legal receiver
// whose text contains a '(' BEFORE the callee's dot, so the cut lands inside
// the receiver and the dot disappears.  Golden renders each of these as a
// method call; the question is whether we still do.
class obj22p;
   string p22p;
   function string path22p();
      return p22p;
   endfunction
endclass

interface if22p;
   function void poke22p(string a_name, int a_kind);
   endfunction
endinterface

class holder22p;
   virtual if22p vif22p;
   virtual if22p bank22p[4];
   obj22p o22p;

   function int idx22p(int a_i);
      return a_i;
   endfunction

   // p01 PARENTHESIZED INDEX — the '(' precedes the callee's dot.
   function void p01_parenidx(int a_i, string a_s);
      bank22p[(a_i)].poke22p(a_s, 1);
   endfunction

   // p02 FUNCTION-CALL INDEX.
   function void p02_callidx(int a_i, string a_s);
      bank22p[idx22p(a_i)].poke22p(a_s, 2);
   endfunction

   // p03 CAST INDEX.
   function void p03_castidx(int a_i, string a_s);
      bank22p[int'(a_i)].poke22p(a_s, 3);
   endfunction

   // p04 PARENTHESIZED INDEX + receiver-qualified ARGUMENT (both faces at once).
   function void p04_parenidxarg(int a_i);
      bank22p[(a_i)].poke22p(o22p.path22p(), 4);
   endfunction

   // p05 CONTROL — plain index, no paren before the dot.  Must not move.
   function void p05_plainidx(int a_i, string a_s);
      bank22p[a_i].poke22p(a_s, 5);
   endfunction

   // p06 CONTROL — unsubscripted qualified callee.  Must not move.
   function void p06_plain(string a_s);
      vif22p.poke22p(a_s, 6);
   endfunction
endclass

module mod22p;
   holder22p hh22p;
endmodule
