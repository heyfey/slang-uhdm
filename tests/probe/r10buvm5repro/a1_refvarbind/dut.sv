// r10buvm5 arm a1 -- WHEN does golden attach vpiActual to a bare reference to a
// SUBROUTINE-LOCAL whose declaration came out as a `ref_var`?
//
// The BuildUVMPkg head is one cell of this: `m_inst_aliases.push_back(
// orig_type_alias_per_inst)` inside an out-of-body method, where golden's
// argument ref_obj carries NO vpiActual and ours points at the ref_var.
//
// Every cell below declares a local of a type Surelog does NOT resolve to a
// variable kind (a package typedef of a parameterised class specialisation, and
// a class-nested struct typedef -- the two spellings the corpus actually uses),
// and then references it from ONE position.  The positions are the ones the
// corpus separates:
//
//   P1  statement-level user METHOD call argument, SAME block as the decl
//   P2  statement-level user METHOD call argument, NESTED block
//   P3  statement-level plain user FUNCTION call argument, SAME block
//   P4  statement-level plain user FUNCTION call argument, NESTED block
//   P5  if CONDITION, bare operand, SAME block
//   P6  if CONDITION, bare operand, NESTED block
//   P7  if CONDITION, $cast (SYSTEM call) argument, SAME block
//   P8  if CONDITION, $cast argument, NESTED block
//   P9  if CONDITION, user METHOD call argument (the try_put/try_get shape)
//   P10 assignment LHS, SAME block
//   P11 assignment RHS, SAME block
//
// Every method is written OUT OF BODY, because that is what the head is; the
// in-class twin is arm a2.
package p5;

  class box5 #(type T5 = int);
    T5 v5;
    function void put5(T5 a5); v5 = a5; endfunction
    function int  chk5(T5 a5); return 1; endfunction
  endclass

  typedef box5 #(int) bi5_t;

  // the try_put/try_get shape: a member whose method takes the LOCAL's own type,
  // so P9 can put a user METHOD CALL inside an if CONDITION.
  class port5_c;
    function int try5(bi5_t a5); return 1; endfunction
  endclass

  class own5;
    typedef struct { int a5; int b5; } st5_t;

    protected bi5_t  hold5[$];
    protected st5_t  sq5[$];
    protected bi5_t    fifo5;
    protected port5_c  port5;

    extern function void p1_5(int m5);
    extern function void p2_5(int m5);
    extern function void p3_5(int m5);
    extern function void p4_5(int m5);
    extern function void p5_5(int m5);
    extern function void p6_5(int m5);
    extern function void p7_5(int m5);
    extern function void p8_5(int m5);
    extern function void p9_5(int m5);
    extern function void p10_5(int m5);
    extern function void p11_5(int m5);
    extern function void s1_5(int m5);
    extern function void s2_5(int m5);
    function void take5(bi5_t a5); endfunction
  endclass

  function void sink5(bi5_t a5); endfunction

  // ---------------------------------------------------------------- P1 / P2
  function void own5::p1_5(int m5);
    bi5_t v5;
    hold5.push_back(v5);                 // P1 same block, method call arg
  endfunction

  function void own5::p2_5(int m5);
    bi5_t v5;
    if (m5 == 0) begin
      hold5.push_back(v5);               // P2 nested block, method call arg
    end
  endfunction

  // ---------------------------------------------------------------- P3 / P4
  function void own5::p3_5(int m5);
    bi5_t v5;
    sink5(v5);                           // P3 same block, plain call arg
  endfunction

  function void own5::p4_5(int m5);
    bi5_t v5;
    if (m5 == 0) begin
      sink5(v5);                         // P4 nested block, plain call arg
    end
  endfunction

  // ---------------------------------------------------------------- P5 / P6
  function void own5::p5_5(int m5);
    bi5_t v5;
    if (v5 == null) m5 = 1;              // P5 same block, bare in condition
  endfunction

  function void own5::p6_5(int m5);
    bi5_t v5;
    if (m5 == 0) begin
      if (v5 == null) m5 = 1;            // P6 nested block, bare in condition
    end
  endfunction

  // ---------------------------------------------------------------- P7 / P8
  function void own5::p7_5(int m5);
    bi5_t v5;
    if (!$cast(v5, fifo5)) m5 = 1;       // P7 same block, $cast arg
  endfunction

  function void own5::p8_5(int m5);
    bi5_t v5;
    if (m5 == 0) begin
      if (!$cast(v5, fifo5)) m5 = 1;     // P8 nested block, $cast arg
    end
  endfunction

  // ---------------------------------------------------------------- P9
  function void own5::p9_5(int m5);
    bi5_t v5;
    if (port5.try5(v5) == 0) m5 = 1;     // P9 method call arg INSIDE a condition
  endfunction

  // ---------------------------------------------------------------- P10 / P11
  function void own5::p10_5(int m5);
    bi5_t v5;
    v5 = fifo5;                          // P10 assignment LHS, same block
  endfunction

  function void own5::p11_5(int m5);
    bi5_t v5;
    bi5_t w5;
    w5 = v5;                             // P11 assignment RHS, same block
  endfunction

  // -------------------------------------------------- the class-nested struct
  // (the head's own spelling: a struct typedef declared INSIDE the class,
  // pushed onto a queue of that type)
  function void own5::s1_5(int m5);
    st5_t u5;
    sq5.push_back(u5);                   // S1 same block
  endfunction

  function void own5::s2_5(int m5);
    st5_t u5;
    if (m5 == 0) begin
      sq5.push_back(u5);                 // S2 nested block  <- THE HEAD's cell
    end
  endfunction

endpackage
