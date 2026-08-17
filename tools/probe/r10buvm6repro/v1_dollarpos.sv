// r10buvm6 arm 1 — WHERE does golden mint the `$` bound as an INDEX object?
//
// The corpus head is uvm_pkg.sv:12983 `m_override_info.push_back(matched_overrides[$])`:
// golden's bit_select carries a vpiIndex constant (vpiDecompile:$, vpiSize:1,
// STRING:$, vpiConstType:10) and we emit no index at all.  This arm puts the SAME
// `$` in every position the language allows, so the law is read off golden rather
// than generalised from one cell.
//
// Cell naming: p## = position.  Every cell is a queue read/write of ONE `$`
// (or a `$`-containing index expression), and NOTHING else varies.
package p6;

  typedef struct {
    int f;
    int g;
  } st6_t;

  class c6;
    int      q6[$];        // the plain queue
    string   s6[$];
    st6_t    t6[$];
    int      qq6[2][$];    // fixed outer, queue inner
    int      hold6[$];

    // ---------------- p01: the CORPUS SHAPE — [$] as a METHOD-CALL ARGUMENT
    function void p01();
      hold6.push_back(q6[$]);
    endfunction

    // ---------------- p02: [$] as a RETURN expression (uvm_printer:20128 shape)
    function int p02();
      return q6[$];
    endfunction

    // ---------------- p03: [$] as an ASSIGNMENT RHS
    function void p03();
      int v;
      v = q6[$];
    endfunction

    // ---------------- p04: [$] as an ASSIGNMENT LHS (a queue back-element write)
    function void p04();
      q6[$] = 7;
    endfunction

    // ---------------- p05: [$] inside an IF CONDITION
    function int p05();
      if (q6[$] == 0) return 1;
      return 0;
    endfunction

    // ---------------- p06: [$] as an OPERAND of an arithmetic operation
    function int p06();
      int v;
      v = q6[$] + 1;
      return v;
    endfunction

    // ---------------- p07: [$-1] — an INDEX OPERATION containing `$`
    function int p07();
      int v;
      v = q6[$-1];
      return v;
    endfunction

    // ---------------- p08: [$-1] as a CALL ARGUMENT
    function void p08();
      hold6.push_back(q6[$-1]);
    endfunction

    // ---------------- p09: [$] then a MEMBER ACCESS  (t6[$].f)
    function int p09();
      int v;
      v = t6[$].f;
      return v;
    endfunction

    // ---------------- p10: NESTED select with `$` in the INNER dim (qq6[1][$])
    function int p10();
      int v;
      v = qq6[1][$];
      return v;
    endfunction

    // ---------------- p11: a PART SELECT with `$` as the RIGHT bound (q6[1:$])
    function void p11();
      int r[$];
      r = q6[1:$];
    endfunction

    // ---------------- p12: a PART SELECT with `$` as the LEFT bound (q6[$:1])
    //  (`$:1` is illegal as a select; the legal `$`-left form is a queue MAX
    //   bound in a declaration, which cell d01 below carries.  The rvalue twin
    //   kept here is `q6[0:$]` — the WHOLE-queue slice.)
    function void p12();
      int r[$];
      r = q6[0:$];
    endfunction

    // ---------------- p13: a PART SELECT slice inside a CONCATENATION
    //  (Google chapter-7 `q = { q[0:1], 10, q[2:$] }` shape)
    function void p13();
      int r[$];
      r = {q6[0:0], q6[1:$]};
    endfunction

    // ---------------- p14: [$] as a SYSTEM-CALL argument
    function void p14();
      $display("%0d", q6[$]);
    endfunction

    // ---------------- p15: [$] on a STRING queue (element type varies)
    function void p15();
      string sv;
      sv = s6[$];
    endfunction

    // ---------------- p16: [$] read TWICE in ONE expression
    function int p16();
      int v;
      v = q6[$] + q6[$];
      return v;
    endfunction

    // ---------------- p17: [$] as a CASE expression
    function int p17();
      case (q6[$])
        0: return 1;
        default: return 2;
      endcase
    endfunction

    // ---------------- p18: `$` as a whole CALL ARGUMENT (not a select at all)
    //  `q6[$]` is the select; this is `$` handed straight to a formal that
    //  accepts an unbounded value.  Kept separate because our new arm would
    //  fire here too.
    function void p18();
      hold6.push_back(q6.size());
    endfunction

  endclass

  // ---------------- d01: a BOUNDED-queue DECLARATION (`int q[$:2]`) — the
  // `$` that is a TYPE bound, not an index.  Present so the arm shows whether
  // the two `$` populations share one object shape.
  class c6b;
    int qb6[$:2];
    function int d01();
      return qb6[$];
    endfunction
  endclass

endpackage

module mdollar6;
  // The MODULE-scope twin of p01/p03: an initial block, not a class method,
  // so a rule keyed on reader context would show up here.
  int mq6[$];
  int mv6;
  initial begin
    mq6.push_back(1);
    mv6 = mq6[$];
    mq6[$] = 3;
  end
endmodule
