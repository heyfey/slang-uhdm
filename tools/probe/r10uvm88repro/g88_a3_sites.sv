// r10uvm88 arm a3 — WHICH POSITIONS inside an in-body class method carry the
// reference.  The corpus head is a METHOD-CALL ARGUMENT under an `if`; this arm
// reads every other position off ONE golden so the law is not written for one
// syntactic slot.
package s88;
  const string  cs88 = "CS";
  const int     ci88 = 3;
  int           nv88 = 4;
  string        arr88[$];

  class t88;
    string m;
    int    n;
    function void sink88(string a, int b); m = a; n = b; endfunction
    static function void stat88(); endfunction

    // (1) CONSTRUCTOR — the corpus head's own kind (uvm_port_base::new)
    function new();
      m = cs88;
    endfunction
    // (2) a METHOD-CALL ARGUMENT under an `if` — the head verbatim
    function void call88(bit c);
      if (c) sink88(cs88, ci88);
    endfunction
    // (3) an ASSIGNMENT RHS, an assignment LHS, a compound operand
    function void asg88();
      m  = cs88;
      n  = ci88 + nv88;
      nv88 = 5;                 // the package variable AS THE LHS
    endfunction
    // (4) a RETURN expression
    function string ret88(); return cs88; endfunction
    // (5) an `if` CONDITION and a `while`/`for` condition
    function void cond88();
      if (nv88 == ci88) m = cs88;
      while (nv88 > 0) nv88 = nv88 - 1;
      for (int i = 0; i < ci88; i++) n = i;
    endfunction
    // (6) a CASE selector and a case item
    function void case88();
      case (nv88)
        ci88: m = cs88;
        default: m = "";
      endcase
    endfunction
    // (7) a NESTED BLOCK and a foreach body
    function void nest88();
      begin : blk88
        m = cs88;
        foreach (arr88[i]) m = {m, cs88};
      end
    endfunction
    // (8) a SYSTEM-CALL argument
    function void sys88(); m = $sformatf("%s%0d", cs88, ci88); endfunction
    // (9) a STATIC in-body method
    static function string sf88(); return cs88; endfunction
    // (10) a TASK in-body
    task tk88(); m = cs88; endtask
    // (11) a VIRTUAL in-body method
    virtual function void vf88(); m = cs88; endfunction
    // (12) a class PROPERTY INITIALISER reading the package variable
    string p88 = cs88;
  endclass

  // (13) an in-body method of a PARAMETERIZED class (the corpus shape:
  //      uvm_port_base #(type IF=uvm_void))
  class u88 #(type T = int);
    string m;
    T      v;
    function void pinb88(); m = cs88; endfunction
  endclass

  // (14) a DERIVED class's in-body method
  class w88 extends t88;
    function void dinb88(); m = cs88; endfunction
  endclass
endpackage

module tops88;
  s88::t88 h;
  s88::u88 #(int) g;
  s88::w88 w;
  initial begin h = new(); g = new(); w = new(); end
endmodule
