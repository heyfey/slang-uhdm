// r10v222 — ADVERSARIAL ARM E: an ESCAPED identifier that CONTAINS a '('.
// § 222's a5 measured an escaped receiver containing a DOT; an escaped name
// may equally contain a '(' — it runs to the next whitespace — and then the
// patched cut lands inside the NAME itself.
interface if22e;
   function void poke22e(string a_name, int a_kind);
   endfunction
endinterface

class obj22e;
   string p22e;
   function string path22e();
      return p22e;
   endfunction
endclass

class hold22e;
   virtual if22e \vif(par22e ;
   virtual if22e vif22e;
   obj22e o22e;

   // e11 ESCAPED receiver whose name contains '(' — plain argument.
   function void e11_escparen(string a_s);
      \vif(par22e .poke22e(a_s, 11);
   endfunction

   // e12 same receiver, receiver-qualified argument.
   function void e12_escparenarg();
      \vif(par22e .poke22e(o22e.path22e(), 12);
   endfunction

   // e13 CONTROL — ordinary receiver, must not move.
   function void e13_plain(string a_s);
      vif22e.poke22e(a_s, 13);
   endfunction
endclass

module mod22e2;
   hold22e h22e;
endmodule
