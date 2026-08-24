// r10buvm34repro/g34a1.sv — § foreachScopedArrayLoopVarIntFallback34, ARM 1:
// THE ARRAY-TYPE MATRIX.  Every cell is the SAME out-of-body class method (the
// corpus home shape: `uvm_sequence_library::init_sequence_library`, written at
// package scope), each array iterated TWICE — once written `this_type::<a>`
// (the law's face) and once written bare (the RESOLVABLE control that pins
// golden's kind table).  Read cell by cell; MEASUREMENT ONLY.
package p34;

  typedef enum bit [2:0] { E0 = 0, E1 = 1 } e34_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } sp34_t;
  typedef int ta34_t[4];

  class key34;
    int k;
  endclass

  class der34;
    typedef der34 this_type;
    static int    q34   [$];        // queue of int
    static int    d34   [];         // dynamic of int
    static int    f34   [4];        // fixed of int
    static string sq34  [$];        // queue of string
    static key34  cq34  [$];        // queue of class handles
    static int    as34  [string];   // associative [string]
    static int    ai34  [int];      // associative [int]
    static int    ac34  [key34];    // associative [class]
    static e34_t  eq34  [$];        // queue of enum
    static sp34_t pq34  [$];        // queue of packed struct
    static bit [7:0] v34;           // PACKED vector (no unpacked dim)
    static int    m34   [3][4];     // multi-dim fixed
    static ta34_t t34;              // a TYPEDEF'd fixed array
    extern function void oob34();
  endclass

  function void der34::oob34();
    int r34;
    // ---- SCOPED (the law) ------------------------------------------------
    foreach (this_type::q34 [i]) r34 = i;      // A1  queue<int>
    foreach (this_type::d34 [i]) r34 = i;      // A2  dynamic<int>
    foreach (this_type::f34 [i]) r34 = i;      // A3  fixed<int>
    foreach (this_type::sq34[i]) r34 = i;      // A4  queue<string>
    foreach (this_type::cq34[i]) r34 = i;      // A5  queue<class>
    foreach (this_type::as34[i]) r34 = 1;      // A6  assoc[string]
    foreach (this_type::ai34[i]) r34 = i;      // A7  assoc[int]
    foreach (this_type::ac34[i]) r34 = 1;      // A8  assoc[class]
    foreach (this_type::eq34[i]) r34 = i;      // A9  queue<enum>
    foreach (this_type::pq34[i]) r34 = i;      // A10 queue<packed struct>
    foreach (this_type::v34 [i]) r34 = i;      // A11 PACKED vector
    foreach (this_type::m34 [i,j]) r34 = i+j;  // A12 multi-dim [i,j]
    foreach (this_type::t34 [i]) r34 = i;      // A13 typedef'd fixed
    // ---- BARE (the resolvable controls) ----------------------------------
    foreach (q34 [i]) r34 = i;                 // C1
    foreach (d34 [i]) r34 = i;                 // C2
    foreach (f34 [i]) r34 = i;                 // C3
    foreach (sq34[i]) r34 = i;                 // C4
    foreach (cq34[i]) r34 = i;                 // C5
    foreach (as34[i]) r34 = 1;                 // C6
    foreach (ai34[i]) r34 = i;                 // C7
    foreach (ac34[i]) r34 = 1;                 // C8
    foreach (eq34[i]) r34 = i;                 // C9
    foreach (pq34[i]) r34 = i;                 // C10
    foreach (v34 [i]) r34 = i;                 // C11
    foreach (m34 [i,j]) r34 = i+j;             // C12
    foreach (t34 [i]) r34 = i;                 // C13
  endfunction

endpackage
