// r10vbuvm34repro/v34d.sv — VERIFIER ARM D: array SHAPES and PROPERTY
// QUALIFIERS the type matrix did not reach — array of STRUCTS, queue of queue,
// multi-dim [4][string], 2-D associative, class-handle array, plus protected /
// local / static / rand / const properties and a class declared in a MODULE.
// MEASUREMENT ONLY.
package sd34;
  typedef struct { int a; int b; } us34_t;      // UNPACKED struct
  typedef struct packed { bit [3:0] a; bit [3:0] b; } ps34_t;
  class kd34; int k; endclass

  class cd34;
    typedef cd34 this_type;
    static us34_t     su34 [4];        // array of UNPACKED structs
    static ps34_t     sp34 [4];        // array of PACKED structs
    static int        sqq34[$][$];     // queue of queue
    static int        sms34[4][string];// multi-dim [4][string]
    static int        s2a34[string][string]; // 2-D associative
    static kd34       sch34[4];        // fixed array of class handles
    protected static int spr34[$];
    local     static int slo34[$];
    static    int        sst34[$];
    const     static int scn34[4] = '{1,2,3,4};
    extern function void oob34();
  endclass

  function void cd34::oob34();
    int r;
    foreach (this_type::su34 [i])   r = i;      // D1  array of unpacked struct
    foreach (this_type::sp34 [i])   r = i;      // D2  array of packed struct
    foreach (this_type::sqq34[i,j]) r = i+j;    // D3  queue of queue
    foreach (this_type::sms34[i,j]) r = i;      // D4  [4][string]
    foreach (this_type::s2a34[i,j]) r = 1;      // D5  [string][string]
    foreach (this_type::sch34[i])   r = i;      // D6  array of class handles
    foreach (this_type::spr34[i])   r = i;      // D7  protected
    foreach (this_type::slo34[i])   r = i;      // D8  local
    foreach (this_type::sst34[i])   r = i;      // D9  static
    foreach (this_type::scn34[i])   r = i;      // D10 const
    // bare twins
    foreach (su34 [i])   r = i;                 // E1
    foreach (sp34 [i])   r = i;                 // E2
    foreach (sqq34[i,j]) r = i+j;               // E3
    foreach (sms34[i,j]) r = i;                 // E4
    foreach (s2a34[i,j]) r = 1;                 // E5
    foreach (sch34[i])   r = i;                 // E6
    foreach (spr34[i])   r = i;                 // E7
    foreach (slo34[i])   r = i;                 // E8
    foreach (sst34[i])   r = i;                 // E9
    foreach (scn34[i])   r = i;                 // E10
  endfunction
endpackage

module md34;
  // a class declared INSIDE a module
  class inm34;
    typedef inm34 this_type;
    static int mq34 [$];
    static int ma34 [string];
  endclass
  int r34;
  initial begin
    foreach (inm34::mq34[i]) r34 = i;           // M1 module-declared class
    foreach (inm34::ma34[i]) r34 = 1;           // M2
  end
endmodule

module topd34;
  import sd34::*;
  int r34;
  md34 u1();
  initial begin
    foreach (cd34::su34[i])  r34 = i;           // T1 module home, unpacked struct
    foreach (cd34::sms34[i,j]) r34 = i;         // T2 module home, [4][string]
    foreach (cd34::s2a34[i,j]) r34 = 1;         // T3 module home, [str][str]
  end
endmodule
