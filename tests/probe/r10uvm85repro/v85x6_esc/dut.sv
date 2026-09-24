// v85x6 — THE OTHER HALF OF THE NET QUESTION.  The pristine emitter minted a
// module net named `this` out of its ref_obj prefix (arm a8 L23, golden has
// none).  Here the module GENUINELY declares one — only spellable escaped — in
// the same module that hoists an out-of-body class method carrying the head
// statement, so a law that deleted the net would show up as golden-only.
//   (`\this .delete(k)` as a RECEIVER is not testable: slang resolves the
//    escaped name to the implicit handle and rejects the member.  An escaped
//    `\super` NET assigned in an initial block ABORTS BOTH BINARIES — a
//    PRE-EXISTING defect, so it is not spelled here.)
package p85x6;
  class c6v;
    string   sequences[$];
    int      n;
    extern function void oob6(string t);
  endclass
  function void c6v::oob6(string t);
    for (int i = 0; i < this.sequences.size(); i++) begin
      if (this.sequences[i] == t)
        this.sequences.delete(i);
    end
    this.sequences.push_back(t);
    this.n = 1;
  endfunction
endpackage
module v85x6;
  import p85x6::*;
  logic \this ;
  c6v h;
  initial \this = 1'b0;
endmodule
