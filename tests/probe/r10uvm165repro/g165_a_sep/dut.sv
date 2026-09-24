// r10uvm165 arm A — THE SEPARATOR.
// ONE in-body class method holds the SAME call, with the SAME formal as its
// bare argument, at the two positions the corpus head puts it in:
//   uvm_registry.svh:595  m__type_aliases.push_back(alias_name);   golden BINDS
//   uvm_registry.svh:601  factory.set_type_alias(alias_name,rgtry) golden BARE
// The corpus differs in THREE things at once (receiver kind: class PROPERTY vs
// LOCAL handle; callee: BUILT-IN vs USER method; nesting: top level vs two if
// bodies deep).  This arm crosses all three so exactly one of them can carry
// the rule.  MEASUREMENT ONLY.
package quillpk165;

  class Ledger165;
     function void stamp(string mark);
     endfunction
     static function void brand(string mark);
     endfunction
  endclass

  class Registry165;
     static string   m_marks[$];
     static Ledger165 s_ledger;
     static bit      ready;

     static function void enroll(string mark);
        Ledger165 book = null;

        // ---------------- DEPTH 0 (function top level) ----------------
        m_marks.push_back(mark);          // a01 builtin  on class PROPERTY
        book.stamp(mark);                 // a02 user     on LOCAL handle
        s_ledger.stamp(mark);             // a03 user     on class PROPERTY handle
        Ledger165::brand(mark);           // a04 user     STATIC path receiver
        m_marks.push_front(mark);         // a05 builtin  on class PROPERTY

        // ---------------- DEPTH 1 (one if body) ----------------
        if (ready) begin
           m_marks.push_back(mark);       // a11 builtin  on class PROPERTY
           book.stamp(mark);              // a12 user     on LOCAL handle
           s_ledger.stamp(mark);          // a13 user     on class PROPERTY handle
           Ledger165::brand(mark);        // a14 user     STATIC path receiver
        end

        // ---------------- DEPTH 2 (the corpus shape) ----------------
        if (ready) begin
           Ledger165 tome = null;
           if (book != null) begin
              m_marks.push_back(mark);    // a21 builtin  on class PROPERTY
              book.stamp(mark);           // a22 user     on LOCAL handle
              tome.stamp(mark);           // a23 user     on BLOCK-LOCAL handle
              s_ledger.stamp(mark);       // a24 user     on class PROPERTY handle
              Ledger165::brand(mark);     // a25 user     STATIC path receiver
           end
        end
     endfunction

     // the NON-static twin, so `this.` and a plain instance property receiver
     // are on the same golden.
     Ledger165 i_ledger;
     string    i_marks[$];
     function void inscribe(string mark);
        Ledger165 folio = null;
        i_marks.push_back(mark);          // a31 builtin on INSTANCE property, d0
        i_ledger.stamp(mark);             // a32 user    on INSTANCE property, d0
        this.i_ledger.stamp(mark);        // a33 user    through `this.`,      d0
        folio.stamp(mark);                // a34 user    on LOCAL handle,      d0
        if (ready) begin
           i_marks.push_back(mark);       // a41 d1
           i_ledger.stamp(mark);          // a42 d1
           this.i_ledger.stamp(mark);     // a43 d1
           folio.stamp(mark);             // a44 d1
        end
     endfunction
  endclass
endpackage
