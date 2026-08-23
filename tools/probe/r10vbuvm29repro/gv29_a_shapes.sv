// r10vbuvm29 arm A (VERIFIER) — STREAM SHAPES the implementer's arm A did not
// reach, all under a WRITTEN cast: with-ranges, a nested stream, a PARAMETER
// slice size, a TYPEDEF'd keyword slice size, a queue source, an associative
// source, a multi-member fixed list, and a stream over a class property.
//
// NOTE measured here: slang REJECTS a bit-stream cast whose stream is
// FIXED-SIZE and does not match the target's width ("streaming concatenation
// cannot be converted to type 'int'"), so every cell below either streams a
// DYNAMICALLY sized source (the head's own shape) or matches the width.
package va29;
  parameter int SL = 4;
  typedef bit [7:0] byte_t;
  class C;
    int i1; bit [31:0] w1; byte b1;
    bit  __a[];
    byte __c[];
    int  __q[$];
    bit  __d[];
    function void f();
      // WITH-RANGE: slang REJECTS a bit-stream cast over a with-ranged
      // stream ("streaming concatenation cannot be converted to type 'int'"),
      // so the with-range cells live in the BARE (uncast) fence arm instead.
      // NESTED stream inside the cast operand
      i1 = int'({ << bit { { >> bit { __a }} }});
      // PARAMETER slice size
      i1 = int'({ << SL { __a }});
      // TYPEDEF'd keyword slice size
      i1 = int'({ << byte_t { __c }});
      // queue source
      i1 = int'({ << 8 { __q }});
      // TWO dynamic members
      i1 = int'({ << bit { __a, __d }});
      // width-MATCHED fixed source (32 bits into int)
      i1 = int'({ << bit { w1 }});
      i1 = int'({ >> 8 { w1 }});
      // a class PROPERTY streamed under a cast
      i1 = int'({ << bit { this.__a }});
    endfunction
  endclass
endpackage
