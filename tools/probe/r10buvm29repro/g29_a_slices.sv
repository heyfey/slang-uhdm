// r10buvm29 arm A — the STREAM SHAPE under a written cast.
// Varies ONLY the streaming operand (direction, slice size, member count);
// the target type and the carrier are held at `int` / assignment-Rhs.
// Lines 12..21 are the law's cells; 23..25 are CONTROLS that must not move
// (a cast over a non-stream operand, already correct pristine).
package a29;
  class C;
    int i1; bit [7:0] v1; byte b1;
    function void f();
      bit  __a[];
      byte __c[];
      i1 = int'({ << bit { __a }});        // implicit-typed slice, one member
      i1 = int'({ >> bit { __a }});        // the >> direction
      i1 = int'({ << { __a }});            // NO slice size at all
      i1 = int'({ >> { __a }});
      i1 = int'({ << 8 { __a }});          // a NUMERIC slice size
      i1 = int'({ >> 8 { __a }});
      i1 = int'({ << byte { __c }});       // a keyword slice size
      i1 = shortint'({ << bit { v1, b1 }});  // TWO stream members
      i1 = int'({ << bit { v1, b1, v1, b1 }}); // FOUR stream members
      i1 = int'({ << bit { __a, __c }});   // two dynamic-array members
      i1 = int'(v1);                       // CONTROL: cast, no stream
      i1 = int'({ v1, v1 });               // CONTROL: cast over a concat
      i1 = int'(int'(v1));                 // CONTROL: nested cast
    endfunction
  endclass
endpackage
