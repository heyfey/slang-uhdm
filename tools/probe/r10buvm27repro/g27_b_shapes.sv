// r10buvm27 grid B -- $bits(<binary op>) : LEFTMOST-OPERAND shape x HOME x POSITION
package pB;
  typedef struct packed { bit [3:0] hi; bit [7:0] lo; } sp_t;      // 12
  typedef struct packed { bit [1:0] a; bit [2:0] b; } inner_t;     // 5
  typedef struct packed { inner_t in; bit [7:0] w; } outer_t;      // 13
  parameter int PW = 5;

  class C;
    byte unsigned  b8;
    byte unsigned  dyn [];
    byte unsigned  q   [$];
    byte unsigned  aa  [string];
    bit  [31:0]    v32;
    logic [7:0]    pk4 [4];
    logic [7:0]    md  [2][3];
    int            ii;
    sp_t           sp;
    outer_t        ou;
    string         st;
    real           rr;
    time           tt;
    C              hnd;
    typedef enum bit [2:0] { E0, E1 } e_t;
    e_t            ee;
    function int f(int a); return a; endfunction
    function void m();
      int r; int i; byte unsigned be;
      // ---------- leftmost-operand SHAPES in a binary
      r = $bits(dyn[i] & be);        // b01 select over dynamic  -> 8?
      r = $bits(q[i] & be);          // b02 select over queue
      r = $bits(aa["k"] & be);       // b03 select over assoc
      r = $bits(pk4[i] & be);        // b04 select over fixed unpacked  -> 32?
      r = $bits(md[i][1] & be);      // b05 2-D select
      r = $bits(v32[3] & be);        // b06 bit select of packed vector -> 32
      r = $bits(v32[7:0] & be);      // b07 part select                 -> 32
      r = $bits(v32[i+:4] & be);     // b08 indexed part select
      r = $bits(sp.hi & be);         // b09 member                      -> ?
      r = $bits(ou.in.b & be);       // b10 nested member
      r = $bits(this.b8 & be);       // b11 this-qualified
      r = $bits(hnd.b8 & be);        // b12 handle-qualified
      r = $bits(ee & be);            // b13 bare enum name  (KEEP expected)
      r = $bits(st.len() & be);      // b14 method call
      r = $bits(f(1) & be);          // b15 function call
      r = $bits(dyn[i] & v32);       // b16 wider rhs, select lhs
      r = $bits(be & dyn[i]);        // b17 select on the RIGHT only (KEEP)
      r = $bits(dyn[i] & be & be);   // b18 NESTED binary  (KEEP expected)
      r = $bits((dyn[i]) & be);      // b19 parenthesized lhs
      r = $bits(~dyn[i] & be);       // b20 unary lhs
      r = $bits(dyn[i] + be);        // b21 arithmetic op
      r = $bits(dyn[i] == be);       // b22 comparison op
      r = $bits(dyn[i] ? be : be);   // b23 conditional (lhs is the COND)
      r = $bits({dyn[i], be});       // b24 concatenation
      r = $bits(dyn[i][0] & be);     // b25 select of a select
      r = $bits(sp.hi[1] & be);      // b26 member then select
      r = $bits(rr + 1.0);           // b27 real lhs (bare name, KEEP)
      r = $bits(tt & be);            // b28 time (bare, KEEP)
      // ---------- single-argument twins for the same shapes
      r = $bits(dyn[i]);             // t01
      r = $bits(sp.hi);              // t09
      r = $bits(ou.in.b);            // t10
      r = $bits(md[i][1]);           // t05
      // ---------- POSITION: call argument
      $display("%0d", $bits(dyn[i] & be));   // p01
      r = ff($bits(dyn[i] & be));            // p02
      // ---------- POSITION: index / concat / ternary operand
      r = {$bits(dyn[i] & be)};              // p03
      r = (i ? $bits(dyn[i] & be) : 0);      // p04
      $display("%0d", r, i, be);
    endfunction
    function int ff(int a); return a; endfunction
    extern function void oob();
  endclass
  function void C::oob();                    // OUT-OF-BLOCK home
    int r; int i; byte unsigned be;
    r = $bits(dyn[i] & be);       // o01
    r = $bits(dyn[i]);            // o02
    r = $bits(byte);              // o03
    $display("%0d", r, i, be);
  endfunction

  byte unsigned pdyn [];
  bit  [31:0]   pv32;
  function int pf(int i);
    byte unsigned be;
    int r;
    r = $bits(pdyn[i] & be);      // k01 package function, select lhs
    r = $bits(pv32[3] & be);      // k02
    r = $bits(pdyn[i]);           // k03
    return r;
  endfunction
endpackage

module gB;
  import pB::*;
  byte unsigned mdyn [];
  bit  [31:0]   mv32;
  logic [7:0]   mpk4 [4];
  sp_t          msp;
  byte unsigned mbe;
  int           mi, mr;
  wire [63:0]   wq;
  // cont_assign position
  assign wq = $bits(mpk4[1] & mbe) + $bits(mv32[3] & mbe);   // m01 m02
  localparam int LP1 = $bits(mpk4[1] & 8'h0F);                // m03 localparam init
  localparam int LP2 = $bits(msp.hi & 8'h0F);                 // m04
  parameter  int PP1 = $bits(mv32[3] & 8'h0F);                // m05 parameter init
  initial begin
    mr = $bits(mdyn[mi] & mbe);   // m06 module initial
    mr = $bits(mv32[3] & mbe);    // m07
    mr = $bits(msp.hi & mbe);     // m08
    mr = $bits(mdyn[mi]);         // m09 single-arg twin
    if ($bits(mdyn[mi] & mbe) > 4) mr = 1;  // m10 if condition
    mr = mdyn[$bits(mv32[3] & mbe) % 2];    // m11 index position
    $display("%0d %0d %0d %0d %0d", mr, LP1, LP2, PP1, wq);
    begin C c = new(); c.m(); c.oob(); mr = pf(0); end
  end
endmodule
