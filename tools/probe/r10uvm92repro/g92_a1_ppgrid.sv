// r10uvm92 ARM a1 — THE prettyPrint GRID.  Read off GOLDEN (Surelog) only.
//
// Every statement is a DOTTED path `hh.<member>[<index>]` (so every one is a
// hier_path) whose INDEX is an OPERATION.  The grid crosses
//   * the OPERATOR (every arm of ExprEval::prettyPrint's operation switch, and
//     several arms it has NO row for), and
//   * the OPERAND KIND (constant, ref_obj, hier_path member, this.member,
//     pkg::param, bit_select, part_select, indexed_part_select, plain call,
//     method call, sys call, concat, replication, assignment pattern, nested
//     operation, enum const, cast), and
//   * POSITION (MID = a `.f` follows / TRAIL = the select is last), and
//   * LVAL (assignment lvalue / rvalue / condition / call argument), and
//   * SCOPE (class in-body, class out-of-body, package function, module).
//
// Names are deliberately NOT a/b/c over A/B/C and the numbers are not all the
// same: the brief's "an arm agreeing is not an arm testing" trap.
package q92;

  typedef enum int { RED92 = 3, BLUE92 = 5 } col92;
  typedef struct packed { int hi; int lo; } kt92;
  localparam int PK92 = 6;

  class leaf92;
    int f;
    int deep;
    function int lf(); return 1; endfunction
  endclass

  class hold92;
    leaf92 aidx[];        // DYNAMIC: the head's own shape (m_byte_enable[])
    leaf92 amap[string];
    int    pk;
    string s;
    function int hg(); return 2; endfunction
  endclass

  function automatic int fn92(int x); return x; endfunction

  class t92;
    hold92 hh;
    leaf92 oo;
    int    i, j, k;
    int    ii[8];
    logic [15:0] pkw;
    string s;
    int    res;
    col92  cc;

    function int mg(); return 4; endfunction

    // ============ C: OPERATOR grid, ref_obj + constant operands, TRAIL rvalue
    function void ops();
      // c01 add
      oo = hh.aidx[i+7];
      // c02 sub
      oo = hh.aidx[i-7];
      // c03 mult
      oo = hh.aidx[i*3];
      // c04 div
      oo = hh.aidx[i/2];
      // c05 mod
      oo = hh.aidx[i%9];
      // c06 power
      oo = hh.aidx[i**2];
      // c07 lshift
      oo = hh.aidx[i<<1];
      // c08 rshift
      oo = hh.aidx[i>>1];
      // c09 arith lshift
      oo = hh.aidx[i<<<1];
      // c10 arith rshift
      oo = hh.aidx[i>>>1];
      // c11 bitand
      oo = hh.aidx[i&3];
      // c12 bitor
      oo = hh.aidx[i|3];
      // c13 bitxor
      oo = hh.aidx[i^3];
      // c14 bitxnor
      oo = hh.aidx[i~^3];
      // c15 logand
      oo = hh.aidx[i&&j];
      // c16 logor
      oo = hh.aidx[i||j];
      // c17 eq
      oo = hh.aidx[i==j];
      // c18 neq
      oo = hh.aidx[i!=j];
      // c19 caseeq
      oo = hh.aidx[i===j];
      // c20 caseneq
      oo = hh.aidx[i!==j];
      // c21 gt
      oo = hh.aidx[i>j];
      // c22 ge
      oo = hh.aidx[i>=j];
      // c23 lt
      oo = hh.aidx[i<j];
      // c24 le
      oo = hh.aidx[i<=j];
      // c25 ternary
      oo = hh.aidx[i?j:k];
      // c26 unary minus
      oo = hh.aidx[-i];
      // c27 unary plus
      oo = hh.aidx[+i];
      // c28 unary not
      oo = hh.aidx[!i];
      // c29 unary bitneg
      oo = hh.aidx[~i];
      // c30 unary reduction and
      oo = hh.aidx[&pkw];
      // c31 unary reduction nand
      oo = hh.aidx[~&pkw];
      // c32 unary reduction or
      oo = hh.aidx[|pkw];
      // c33 unary reduction nor
      oo = hh.aidx[~|pkw];
      // c34 unary reduction xor
      oo = hh.aidx[^pkw];
      // c35 unary reduction xnor
      oo = hh.aidx[~^pkw];
      // c36 concat
      oo = hh.aidx[{i,j}];
      // c37 replication
      oo = hh.aidx[{3{i}}];
      // c38 inside
      oo = hh.aidx[i inside {1,2}];
      // c39 wild eq (NO prettyPrint row)
      oo = hh.aidx[i==?j];
      // c40 wild neq (NO prettyPrint row)
      oo = hh.aidx[i!=?j];
      // c41 nested operation, no parens in source
      oo = hh.aidx[i+j*2];
      // c42 nested operation, PARENS in source
      oo = hh.aidx[(i+j)*2];
      // c43 already-spaced source
      oo = hh.aidx[i  +  7];
      // c44 three-deep nest
      oo = hh.aidx[i+j*2-k];
      // c45 cast (NO prettyPrint row for vpiCastOp)
      oo = hh.aidx[int'(i)];
    endfunction

    // ============ D: OPERAND-KIND grid, one operator (+), TRAIL rvalue
    function void kinds();
      // d01 ref_obj + ref_obj
      oo = hh.aidx[i+j];
      // d02 constant + constant
      oo = hh.aidx[4+5];
      // d03 hier_path member operand (THE HEAD's shape)
      oo = hh.aidx[i+oo.f];
      // d04 hier_path member on BOTH sides
      oo = hh.aidx[oo.f+oo.deep];
      // d05 this.member operand
      oo = hh.aidx[i+this.j];
      // d06 bit_select operand
      oo = hh.aidx[i+ii[j]];
      // d07 part_select operand
      oo = hh.aidx[i+pkw[3:0]];
      // d08 indexed part select operand
      oo = hh.aidx[i+pkw[2+:3]];
      // d09 plain (package) func_call operand
      oo = hh.aidx[i+fn92(j)];
      // d10 method_func_call operand, implicit this
      oo = hh.aidx[i+mg()];
      // d11 method_func_call operand, member receiver
      oo = hh.aidx[i+hh.hg()];
      // d12 sys_func_call operand
      oo = hh.aidx[i+$clog2(64)];
      // d13 package localparam operand
      oo = hh.aidx[i+PK92];
      // d14 qualified pkg::param operand
      oo = hh.aidx[i+q92::PK92];
      // d15 enum constant operand
      oo = hh.aidx[i+RED92];
      // d16 enum VARIABLE operand
      oo = hh.aidx[i+int'(cc)];
      // d17 concat operand
      oo = hh.aidx[i+{i,j}];
      // d18 string-keyed map, string operand
      oo = hh.amap[{s,"x"}];
      // d19 hier_path operand FIRST, ref_obj second
      oo = hh.aidx[oo.f+i];
      // d20 call operand on BOTH sides
      oo = hh.aidx[mg()+fn92(j)];
      // d21 hier_path in a TERNARY's condition
      oo = hh.aidx[oo.f?i:j];
      // d22 hier_path as a ternary BRANCH
      oo = hh.aidx[i?oo.f:j];
      // d23 hier_path under a UNARY
      oo = hh.aidx[-oo.f];
      // d24 call under a unary
      oo = hh.aidx[-mg()];
      // d25 hier_path nested one operation deep
      oo = hh.aidx[i+(oo.f*2)];
      // d26 hier_path inside a concat
      oo = hh.aidx[{oo.f,i}];
      // d27 member's own member (2-deep hier_path)
      oo = hh.aidx[i+hh.pk];
    endfunction

    // ============ E: POSITION x LVAL, the head's operand shape (op with a
    //              hier_path operand) and a plain one, four positions each
    function void places();
      // e01 MID   rvalue
      res = hh.aidx[i+oo.f].f;
      // e02 MID   LVALUE
      hh.aidx[i+oo.f].f = 1;
      // e03 TRAIL LVALUE
      hh.aidx[i+oo.f] = null;
      // e04 TRAIL rvalue
      oo = hh.aidx[i+oo.f];
      // e05 TRAIL condition
      if (hh.aidx[i+oo.f] != null) res = 1;
      // e06 TRAIL call argument
      res = fn92(hh.aidx[i+oo.f].f);
      // e07 MID   rvalue, plain operands
      res = hh.aidx[i+2].f;
      // e08 MID   LVALUE, plain operands
      hh.aidx[i+2].f = 1;
      // e09 TRAIL LVALUE, plain operands
      hh.aidx[i+2] = null;
      // e10 TRAIL rvalue, plain operands
      oo = hh.aidx[i+2];
      // e11 MID   rvalue, call operand
      res = hh.aidx[i+mg()].f;
      // e12 TRAIL rvalue, call operand
      oo = hh.aidx[i+mg()];
      // e13 MID, indexed part select whose BASE is an operation
      res = hh.aidx[i+1].f;
      // e14 two selects, both operation indices
      res = hh.aidx[i+1].deep;
    endfunction
  endclass

  // ============ F: OUT-OF-BODY method
  class u92;
    hold92 hh;
    leaf92 oo;
    int i, res;
    extern function void oob();
  endclass
  function void u92::oob();
    // f01 TRAIL rvalue, hier_path operand
    oo = hh.aidx[i+oo.f];
    // f02 MID rvalue, hier_path operand
    res = hh.aidx[i+oo.f].f;
    // f03 TRAIL LVALUE
    hh.aidx[i+oo.f] = null;
    // f04 plain operands
    oo = hh.aidx[i-3];
  endfunction

  // ============ G: PACKAGE-level function
  function automatic int g92();
    hold92 hh = new();
    leaf92 oo = new();
    int i = 1;
    // g01 TRAIL rvalue, hier_path operand
    oo = hh.aidx[i+oo.f];
    // g02 MID rvalue
    return hh.aidx[i+oo.f].f;
  endfunction
endpackage

// ============ H: MODULE scope, struct + interface-free dotted paths
module m92;
  import q92::*;
  typedef struct { int f; int deep; } sleaf92;
  typedef struct { sleaf92 aidx[]; int pk; } shold92;
  shold92 hh;
  sleaf92 oo;
  int i, j, res;
  int ii[8];
  initial begin
    // h01 MID rvalue, plain operands
    res = hh.aidx[i+1].f;
    // h02 MID rvalue, struct-member operand
    res = hh.aidx[i+oo.f].f;
    // h03 MID LVALUE
    hh.aidx[i+oo.f].f = 2;
    // h04 MID rvalue, bit_select operand
    res = hh.aidx[i+ii[j]].f;
    // h05 MID rvalue, sys call operand
    res = hh.aidx[i+$clog2(8)].f;
    // h06 MID rvalue, package param operand
    res = hh.aidx[i+PK92].f;
    // h07 MID rvalue, mod operator + struct member
    res = hh.aidx[i%oo.f].f;
  end
endmodule
