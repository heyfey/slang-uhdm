// verifier probe: WHICH hier_path shapes parent the `$` index?
package xp1;
  typedef struct { int f; int g; } st_t;
  class inner;
    int   q[$];
    st_t  t[$];
  endclass
  class outer;
    inner ih;
    int   q[$];
    st_t  t[$];
    int   v;
    function void body();
      v = t[$].f;        // c1 bare, NON-terminal
      v = q[$];          // c2 bare, terminal
      v = ih.t[$].f;     // c3 handle, NON-terminal
      v = ih.q[$];       // c4 handle, terminal
      v = t[$-1].f;      // c5 bare, NON-terminal, index operation
      v = ih.t[$-1].f;   // c6 handle, NON-terminal, index operation
      v = t[1].f;        // c7 INTEGER twin of c1
      v = ih.t[1].f;     // c8 INTEGER twin of c3
      ih.t[$].f = 3;     // c9 handle, NON-terminal, LVALUE
      t[$].f = 4;        // c10 bare, NON-terminal, LVALUE
    endfunction
  endclass
endpackage
