// r10buvm29 arm C — the CARRIER of a written cast over a stream.
// Varies ONLY where the cast sits: assignment Rhs (the head's own shape),
// call argument, return value, condition, concat member, operand of a binary
// operation, a nested cast, an initialiser, an index.
package c29;
  typedef enum { Z0, Z1 } ze;
  function automatic int g(int x); return x; endfunction
  class C;
    ze e1; int i1; int arr [8];
    function int f();
      bit __a[];
      i1 = int'({ << bit { __a }});                 // assignment Rhs
      i1 = g(int'({ << bit { __a }}));              // call argument
      if (int'({ << bit { __a }}) != 0) i1 = 1;     // condition
      i1 = {int'({ << bit { __a }})};               // concat member
      i1 = 1 + int'({ << bit { __a }});             // binary operand
      i1 = int'(ze'({ << bit { __a }}));            // NESTED: cast of a cast
      arr[int'({ << bit { __a }})] = 3;             // an index
      return int'({ << bit { __a }});               // a return value
    endfunction
  endclass
endpackage
