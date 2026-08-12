// r10svs4repro/v3_escaped.sv — VERIFIER arm: is `nv.symbol.name != "this"`
// REALLY the written-keyword test the shipped comment claims?
//
// The shipped predicate is:
//     if (nv.symbol.name != "this") return nullptr;   // "THE WRITTEN KEYWORD"
// and the comment asserts "slang names the implicit self variable `this`, and
// names it that ONLY when the keyword was written".  SystemVerilog has ESCAPED
// IDENTIFIERS: `\this ` is a legal ordinary identifier whose NAME, after the
// escape is stripped, is the three-plus-one characters `this`.  If slang reports
// `symbol.name == "this"` for it, the predicate fires on a plain struct/class
// variable in a MODULE — no class, no self, no keyword — and erases a select
// golden keeps.
//
// This is the only cell that can distinguish "the symbol is the implicit self"
// from "the symbol's name happens to be the four letters t-h-i-s".
typedef struct { byte b; } sb_t;

module mesc;
   byte \this [4];        // an ESCAPED identifier literally named `this`
   sb_t \that [4];
   int  r;
   int  k;
   initial begin
      r = \this [k];      // x1 escaped-`this` element select, module scope
      r = \that [k].b;    // x2 escaped select-then-member
      \this [k] = 8'h7;   // x3 escaped select LVALUE
   end
endmodule

// The same escaped name INSIDE a class, alongside the real keyword, so the two
// cannot be confused by position.
// REFUTED IN THE STRONGEST WAY: slang resolves the NAME `this` inside a class
// to the IMPLICIT SELF even when an escaped member `\this` is declared, so
// `\this [k]` in a class method does not compile at all ("value of type 'Cesc'
// cannot be indexed").  The escaped-identifier risk therefore exists only at
// MODULE scope, which x1-x3 above measure.
class Cesc;
   byte data[];
   int  r;
   function void f(int k);
      r = this.data[k];   // x5 the REAL keyword (control)
   endfunction
endclass

module mesc2;
   Cesc c;
   initial if (c != null) c.f(1);
endmodule

// THE PRECISE DANGEROUS CELL, added after x1-x3 showed the `mems.empty()` guard
// absorbs a bare escaped select: the predicate needs a MEMBER as well as a
// select, so the shape that can actually reach it at module scope is an escaped
// variable named `this` of a STRUCT type with an ARRAY member.
typedef struct { byte arr[4]; byte s; } holder_t;
module mesc3;
   holder_t \this ;
   int r;
   int k;
   initial begin
      r = \this .arr[k];    // x6 escaped-`this` DOT MEMBER select  <-- the risk
      r = \this .s;         // x7 escaped-`this` unindexed control
      \this .arr[k] = 8'h9; // x8 escaped-`this` member select LVALUE
   end
endmodule
