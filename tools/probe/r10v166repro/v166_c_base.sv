// r10v166 ARM C — the BASE-SPELLING and TARGET-KIND axes, all in a CLASS home,
// so gate (4) is constant and gates (2)/(3) are the only variables.
// Every base below is written as a NAME; what it RESOLVES to varies.
package cs166_pkg;

  class Hnd166;
    int x;
  endclass

  typedef enum logic [2:0] { E166_A, E166_B, E166_C } enum166_t;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pstr166_t;
  typedef struct { int a; string b; } ustr166_t;          // UNPACKED struct
  typedef int    ti166_t;                                  // a KEYWORD alias
  typedef ti166_t tti166_t;                                // alias of an alias
  typedef string tstr166_t;
  typedef logic [7:0] tvec166_t;
  typedef Hnd166 thnd166_t;

  class Base166 #(type TP166 = int, int W166 = 4);
    // --- BASE WRITTEN AS A NAME (the law fires) ---------------------------
    typedef Hnd166    bHnd166_t   [$];       // concrete class handle
    typedef enum166_t bEnum166_t  [$];       // named enum
    typedef pstr166_t bPstr166_t  [$];       // named PACKED struct
    typedef ustr166_t bUstr166_t  [$];       // named UNPACKED struct
    typedef ti166_t   bTdInt166_t [$];       // a typedef OF int
    typedef tti166_t  bTd2166_t   [$];       // a typedef of a typedef of int
    typedef tstr166_t bTdStr166_t [$];       // a typedef OF string
    typedef tvec166_t bVec166_t   [$];       // a typedef of a packed vector
    typedef thnd166_t bTdHnd166_t [$];       // a typedef OF a class handle
    typedef TP166     bTp166_t    [$];       // the class TYPE PARAMETER
    typedef cs166_pkg::Hnd166 bScoped166_t [$];   // SCOPED base name
    typedef bHnd166_t bNest166_t  [$];       // a queue of a queue typedef

    // --- BASE WRITTEN AS A KEYWORD / INLINE (the law must DECLINE) --------
    typedef int    kInt166_t  [$];
    typedef string kStr166_t  [$];
    typedef real   kReal166_t [$];
    typedef bit [7:0] kBit166_t [$];
    typedef enum   { I166_A, I166_B } iEnum166_t [$];      // INLINE enum
    typedef struct packed { logic a; logic b; } iStr166_t [$];  // INLINE struct

    // --- TARGET KINDS off ONE named base ---------------------------------
    typedef Hnd166 tQ166_t [$];              // queue
    typedef Hnd166 tD166_t [];               // dynamic
    typedef Hnd166 tAs166_t [string];        // associative, string key
    typedef Hnd166 tAi166_t [int];           // associative, int key
    typedef Hnd166 tAt166_t [TP166];         // associative, TYPE-PARAM key
    typedef Hnd166 tF166_t [4];              // fixed, literal size
    typedef Hnd166 tFp166_t [W166];          // fixed, PARAMETER size
    typedef Hnd166 tF2166_t [2][3];          // fixed, TWO dims

    function int bases166();
      bHnd166_t    v1166;   bEnum166_t   v2166;   bPstr166_t  v3166;
      bUstr166_t   v4166;   bTdInt166_t  v5166;   bTd2166_t   v6166;
      bTdStr166_t  v7166;   bVec166_t    v8166;   bTdHnd166_t v9166;
      bTp166_t     v10166;  bScoped166_t v11166;  bNest166_t  v12166;
      kInt166_t    d1166;   kStr166_t    d2166;   kReal166_t  d3166;
      kBit166_t    d4166;   iEnum166_t   d5166;   iStr166_t   d6166;
      return v1166.size() + v2166.size() + v3166.size() + v4166.size()
           + v5166.size() + v6166.size() + v7166.size() + v8166.size()
           + v9166.size() + v10166.size() + v11166.size() + v12166.size()
           + d1166.size() + d2166.size() + d3166.size() + d4166.size()
           + d5166.size() + d6166.size();
    endfunction

    string s166_key;
    function int kinds166();
      tQ166_t  q166;  tD166_t  d166;  tAs166_t as166;  tAi166_t ai166;
      tAt166_t at166; tF166_t  f166;  tFp166_t fp166;  tF2166_t f2166;
      int n166;
      d166 = new[2];
      n166 = q166.size() + d166.size() + as166.num() + ai166.num();
      foreach (f166[i166]) if (f166[i166] != null) n166++;
      foreach (f2166[i166, j166]) if (f2166[i166][j166] != null) n166++;
      foreach (fp166[i166]) if (fp166[i166] != null) n166++;
      if (as166.first(s166_key)) n166++;
      return n166;
    endfunction

    // --- QUALIFIERS on the degraded declaration ---------------------------
    function int quals166();
      static    tQ166_t st166;
      automatic tQ166_t au166;
      tQ166_t   init166 = st166;             // WITH INITIALISER
      return st166.size() + au166.size() + init166.size();
    endfunction

    // --- a DERIVED class naming the BASE class's typedef bare -------------
  endclass

  class Derived166 extends Base166 #(int, 4);
    function int der166();
      bHnd166_t dv166;                        // the BASE class's typedef
      tQ166_t   dq166;
      return dv166.size() + dq166.size();
    endfunction
  endclass

  // --- a NESTED class's typedef, and an OUTER class naming it -------------
  class Outer166;
    typedef Hnd166 oq166_t [$];
    class Inner166;
      typedef Hnd166 iq166_t [$];
      function int in166();
        iq166_t iv166;                        // the INNER class's own
        return iv166.size();
      endfunction
    endclass
    function int out166();
      oq166_t ov166;
      return ov166.size();
    endfunction
  endclass

endpackage

module cs166_top;
  import cs166_pkg::*;
  Base166 #(Hnd166, 5) b166;
  Base166 #(int, 4)    c166;
  Derived166           d166;
  Outer166             o166;
  Outer166::Inner166   i166;
  int r166;
  initial begin
    b166 = new(); c166 = new(); d166 = new(); o166 = new(); i166 = new();
    r166 = b166.bases166() + b166.kinds166() + b166.quals166()
         + c166.bases166() + d166.der166() + o166.out166() + i166.in166();
  end
endmodule
