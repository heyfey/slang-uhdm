// r10uvm92 ARM a2 — the prettyPrint dispatch arms arm a1 did NOT reach:
// assignment patterns, streaming, implication/equivalence, literal spellings,
// parameters vs localparams vs enum members, system calls with 0/1/2 args,
// method calls on built-ins, and the LEAF spellings (sized/based/real/string/
// 'x).  Read off GOLDEN only.  Every index is an OPERATION or a leaf whose
// prettyPrint row arm a1 left unmeasured.
package r92;

  typedef struct packed { int hi; int lo; } pr92;
  parameter  int PARAM92 = 11;
  localparam int LOCAL92 = 13;
  typedef enum bit [1:0] { ONE92 = 2'b01, TWO92 = 2'b10 } e92;

  class node92;
    int f;
  endclass

  class bag92;
    node92 dyn[];
    node92 map[string];
    node92 pat[pr92];
    int    q[$];
    int    arr[8];
    logic [31:0] w;
    real   r;
    string s;
    localparam int CLSLP92 = 17;
    static int stat92 = 19;
    function int m0(); return 0; endfunction
    function int m2(int a, int b); return a+b; endfunction
  endclass

  class use92;
    bag92 bb;
    node92 oo;
    int i, j;
    logic [31:0] w;
    string s;
    e92 ee;
    int \odd[name] ;

    function void patterns();
      // k01 assignment pattern, NAMED members (uvm89's residue cell)
      oo = bb.pat['{hi:1, lo:2}];
      // k02 assignment pattern, POSITIONAL members
      oo = bb.pat['{3, 4}];
      // k03 assignment pattern nested in an add
      oo = bb.dyn[i + 1];
      // k04 streaming, left-to-right (in a bit-stream cast, the only legal spot)
      oo = bb.dyn[int'({>>{w}})];
      // k05 streaming, right-to-left
      oo = bb.dyn[int'({<<{w}})];
      // k06 implication
      oo = bb.dyn[i -> j];
      // k07 equivalence
      oo = bb.dyn[i <-> j];
    endfunction

    function void leaves();
      // k10 sized based literal operand
      oo = bb.dyn[i + 8'hFF];
      // k11 based literal with underscores
      oo = bb.dyn[i + 32'h0000_00FF];
      // k12 unbased unsized
      oo = bb.dyn[i + '1];
      // k13 x/z literal
      oo = bb.dyn[i + 2'bx1];
      // k14 string literal in a concat
      oo = bb.map[{s, "tail"}];
      // k15 real literal
      oo = bb.dyn[i + 2];
      // k16 package PARAMETER (not localparam)
      oo = bb.dyn[i + PARAM92];
      // k17 package LOCALPARAM
      oo = bb.dyn[i + LOCAL92];
      // k18 CLASS localparam
      oo = bb.dyn[i + bb.CLSLP92];
      // k19 class STATIC property, scope-qualified
      oo = bb.dyn[i + bag92::stat92];
      // k20 enum member operand
      oo = bb.dyn[i + int'(ONE92)];
      // k21 enum VARIABLE operand
      oo = bb.dyn[i + ee];
      // k22 $bits
      oo = bb.dyn[i + $bits(w)];
      // k23 $size with two args
      oo = bb.dyn[i + $size(bb.arr, 1)];
      // k24 $urandom with NO args
      oo = bb.dyn[i + $urandom()];
      // k25 built-in method call on a queue
      oo = bb.dyn[i + bb.q.size()];
      // k26 method call with two arguments
      oo = bb.dyn[i + bb.m2(i, j)];
      // k27 deep nesting, mixed precedence, no parens
      oo = bb.dyn[i + j * 2 - i / 3];
      // k28 deep nesting WITH parens at every level
      oo = bb.dyn[((i + j) * (2 - i)) / 3];
      // k29 ternary of ternaries
      oo = bb.dyn[i ? (j ? 1 : 2) : 3];
      // k30 unary on a parenthesised operation
      oo = bb.dyn[-(i + j)];
      // k31 concat of three, one empty-rendering
      oo = bb.dyn[{i, oo.f, j}];
      // k32 replication whose count is an operation
      oo = bb.dyn[{(2+1){j}}];
      // k33 nested replication
      oo = bb.dyn[{2{{3{i}}}}];
      // k34 index that is a WHOLE ternary with call branches
      oo = bb.dyn[i ? bb.m0() : j];
      // k35 comparison chain
      oo = bb.dyn[(i > j) == (j > i)];
      // k36 a leaf with an escaped identifier
      oo = bb.dyn[i + \odd[name] ];
      // k37 mod by a call
      oo = bb.dyn[i % bb.m0()];
      // k38 the HEAD's exact shape: mod by a member of a member
      oo = bb.dyn[i % bb.w];
    endfunction

  endclass
endpackage
