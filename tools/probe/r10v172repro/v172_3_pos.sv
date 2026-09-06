// r10v172 arm 3 — POSITION.  The law is a STATEMENT-position law: only a
// `paSubroutine_call_statement` reaches Surelog's compileTfCall.  Every other
// position (assigned, read, condition, argument, return, concatenation) goes
// down compileExpression and must be BYTE-IDENTICAL to pristine.  Also the
// no-such-subroutine control and the plain bare call.  MEASUREMENT ONLY.
package pv3172;
  function int getfn172(); return 1; endfunction

  class bag3172;
    string q172[$];
    int    n172;
    function int size172(); return q172.size(); endfunction
    function void add172(string s); q172.push_back(s); endfunction
  endclass

  class cv3172;
    bag3172 getfn172;                 // the collapsing spelling, as a property
    bag3172 plain172;                 // a spelling that is NOT a subroutine
    int     r172;
    string  s172;

    function void probe172();
      // v3_01 STATEMENT position — the law fires here and only here
      getfn172.q172.push_back("v3_01");
      // v3_02 STATEMENT position, no subroutine of that name — control
      plain172.q172.push_back("v3_02");
      // v3_03 ASSIGNED position — an expression, must not collapse
      r172 = getfn172.size172();
      // v3_04 CONDITION position
      if (getfn172.size172() > 0) r172 = 1;
      // v3_05 ARGUMENT position
      $display("%0d", getfn172.size172());
      // v3_06 a member READ, not a call
      r172 = getfn172.n172;
      // v3_07 a plain bare call statement (one component, no dot)
      r172 = pv3172::getfn172();
      // v3_08 a two-name statement call whose method takes args
      getfn172.add172("v3_08");
      // v3_09 a void'() wrapper — not a subroutine_call_statement
      void'(getfn172.size172());
      // v3_10 the receiver in a for-loop body
      for (int i = 0; i < 2; i++) getfn172.q172.push_back("v3_10");
      // v3_11 inside a fork/join_none
      fork
        getfn172.q172.push_back("v3_11");
      join_none
      // v3_12 inside a case body
      case (r172)
        1: getfn172.q172.push_back("v3_12");
        default: ;
      endcase
      // v3_13 a concatenation read
      s172 = {"x", getfn172.q172[0]};
    endfunction
  endclass
endpackage

module topv3172;
  pv3172::cv3172 c172;
  initial begin
    c172 = new();
    c172.getfn172 = new();
    c172.plain172 = new();
    c172.probe172();
  end
endmodule
