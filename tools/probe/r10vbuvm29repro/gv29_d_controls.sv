// r10vbuvm29 arm D (VERIFIER) — CONTROLS that must NOT move: casts over
// non-stream operands of every shape, BARE streams in every carrier, the sign
// casts, $cast, and the compiler-inserted stream conversions that the fence
// protects.  Any movement here is a REGRESSION.
package vd29;
  typedef enum { Z0, Z1 } ze;
  typedef struct packed { bit [3:0] a, b; } sp;
  function automatic int fc(int x); return x; endfunction
  class C;
    int i1; bit [7:0] v1; byte b1; ze e1; sp s1; int arr[8];
    bit __a[];
    logic [15:0] wide;
    function void f();
      int  r;
      ze   ee;
      // --- casts over NON-stream operands (must be unchanged) ---
      i1 = int'(v1);                       // simple
      i1 = int'({v1, v1});                 // over a concat
      i1 = int'({2{v1}});                  // over a replication
      i1 = int'(fc(1));                    // over a call
      i1 = int'(v1[3:0]);                  // over a part select
      i1 = int'(v1[2]);                    // over a bit select
      i1 = int'(8'hAB);                    // over a literal
      i1 = int'(arr[1]);                   // over an array element
      i1 = int'(int'(v1));                 // nested cast
      e1 = ze'(1);                         // enum target
      s1 = sp'(8'hFF);                     // packed struct target
      // --- BARE streams (compiler-inserted conversion; NO cast node) ---
      i1 = { << bit { __a }};
      i1 = { >> bit { __a }};
      i1 = { << 8 { wide }};
      wide = { >> 8 { wide }};
      wide = { << { wide }};
      r  = { << bit { __a }};
      arr[0] = { << 8 { wide }};
      i1 = fc({ << 8 { wide }});           // bare stream as a call ARGUMENT
      wide = { << 8 { wide }};             // bare, self-assign
      i1 = { << bit { __a with [0:3] }};   // bare, WITH-RANGE (cast form is SLANG_REJECT)
      i1 = { >> bit { __a with [1:2] }};
      // --- streaming concatenation as an ASSIGNMENT TARGET (LHS) ---
      { << bit { __a }} = i1;
      { >> 8 { wide }} = 16'hBEEF;
      // --- sign casts beside a stream ---
      i1 = signed'(v1);
      i1 = unsigned'(v1);
      i1 = signed'(int'({ << bit { __a }}));
      // --- $cast ---
      if ($cast(ee, 1)) i1 = 1;
    endfunction
  endclass
endpackage
