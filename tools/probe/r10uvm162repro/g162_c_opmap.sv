// r10uvm162 grid, arm C — THE OPERATOR MAP, MEASURED NOT GUESSED.
// One ACCEPTED concatenation per written operator, each operator sitting where
// the law will have to mint it (a ternary predicate / a ternary arm), so
// golden's `vpiOpType` for every SyntaxKind the law admits is READ off a
// database instead of transcribed from a header.  Each is written twice, the
// second time in a REJECTED concatenation, so the golden object the recovery
// must produce is on record for every operator.  MEASUREMENT ONLY.
package pc162;
  class basec162;
    function new(string name="x"); endfunction
    function string gname(); return "g"; endfunction
  endclass

  class holdc162 #(type T=int) extends basec162;
    static string sres = "";
    int i, j;
    string prop;

    `define OKBD(n, e) \
      function void ok_``n();      sres = {"[", e, "]"};             endfunction \
      function void bd_``n(); T t; sres = {"[", e, "]", t.gt()};     endfunction

    // BINARY operators, in a ternary predicate.
    `OKBD(c01, (i == j) ? "a" : "b")
    `OKBD(c02, (i != j) ? "a" : "b")
    `OKBD(c03, (i === j) ? "a" : "b")
    `OKBD(c04, (i !== j) ? "a" : "b")
    `OKBD(c05, (i >  j) ? "a" : "b")
    `OKBD(c06, (i >= j) ? "a" : "b")
    `OKBD(c07, (i <  j) ? "a" : "b")
    `OKBD(c08, (i <= j) ? "a" : "b")
    `OKBD(c09, (i && j) ? "a" : "b")
    `OKBD(c10, (i || j) ? "a" : "b")
    `OKBD(c11, (i &  j) ? "a" : "b")
    `OKBD(c12, (i |  j) ? "a" : "b")
    `OKBD(c13, (i ^  j) ? "a" : "b")
    `OKBD(c14, (i +  j) ? "a" : "b")
    `OKBD(c15, (i -  j) ? "a" : "b")
    `OKBD(c16, (i *  j) ? "a" : "b")
    `OKBD(c17, (i /  j) ? "a" : "b")
    `OKBD(c18, (i %  j) ? "a" : "b")
    `OKBD(c19, (i << j) ? "a" : "b")
    `OKBD(c20, (i >> j) ? "a" : "b")
    // UNARY operators.
    `OKBD(c21, (!i) ? "a" : "b")
    `OKBD(c22, (~i) ? "a" : "b")
    `OKBD(c23, (-i) ? "a" : "b")
    `OKBD(c24, (&i) ? "a" : "b")
    `OKBD(c25, (|i) ? "a" : "b")
    // PLAIN DECIMAL literals in every position the law can mint one.
    `OKBD(c26, (i == 7) ? "a" : "b")
    `OKBD(c27, i ? 1 : 0)
    `OKBD(c28, {3{"x"}})
    // A BASED / SIZED literal — the law must ABSTAIN on it unless measured.
    `OKBD(c29, (i == 8'd65) ? "a" : "b")
    `OKBD(c30, (i == 32'h0000_00FF) ? "a" : "b")
    // A REAL literal and a TIME literal — must abstain.
    `OKBD(c31, (i == 1.5) ? "a" : "b")
    // A `null` compared BOTH ways round.
    `OKBD(c32, (null == null) ? "a" : "b")
  endclass
endpackage

module topc162;
  initial $display("hi");
endmodule
