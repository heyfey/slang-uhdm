// r10uvm92 VERIFIER arm b1 — BREAK the prettyPrint law.  Cells the implementer's
// a1/a2/a3 do NOT reach.  Names/orders/numbers deliberately unlike a/b/c.
package zed;

  typedef enum int { GREEN = 7, AMBER = 11 } sig_e;
  localparam int PZ = 9;
  localparam int QZ = 2;

  class twig;
    int fld;
    int alt;
    function int tv(); return 1; endfunction
  endclass

  class nestor;
    twig slot[];
    twig  map[string];
    int   pk;
    int   grid[4][4];
    logic [31:0] wv;
    function int ng(); return 5; endfunction
  endclass

  class deepy;
    twig  one;
    nestor two;
  endclass

  function automatic int fz(int y); return y; endfunction

  class runner;
    nestor nest;
    deepy  mm;
    twig   out1;
    int    k, m;
    int    plain[8];
    int    grid2[4][4];
    logic [31:0] wv;
    logic [7:0]  bw;
    logic [31:0] varr[4];
    string s1;
    sig_e  sg;
    twig   list[];
    parameter int CLSP = 4;

    function int mz(); return 6; endfunction

    // ---------- B: operand kinds a1/a2 do not reach ----------
    function void kinds();
      // b01 RangeSelect over a 2-D ElementSelect base (chain bottoms at NamedValue)
      out1 = nest.slot[k + varr[1][3:0]];
      // b02 2-D ElementSelect operand
      out1 = nest.slot[k + grid2[2][1]];
      // b03 $signed / b04 $unsigned
      out1 = nest.slot[k + $signed(m)];
      out1 = nest.slot[k + $unsigned(m)];
      // b05 $clog2 with a constant argument (does Surelog FOLD it?)
      out1 = nest.slot[k + $clog2(64)];
      // b06 sys call with NO parens
      out1 = nest.slot[k + $bits(wv)];
      // b07 inside with a RANGE element
      out1 = nest.slot[k inside {[1:4]}];
      // b08 inside with exactly ONE element
      out1 = nest.slot[k inside {5}];
      // b09 inside with a range AND a value
      out1 = nest.slot[k inside {[1:4], 9}];
      // b10 single-element concat
      out1 = nest.slot[{k}];
      // b11 double unary minus
      out1 = nest.slot[-(-k)];
      // b12 unary not of unary not
      out1 = nest.slot[!(k > 0)];
      // b13 unbased-unsized operands
      out1 = nest.slot[k + '0];
      out1 = nest.slot[k + '1];
      // b14 signed based literal
      out1 = nest.slot[k + 4'sd3];
      // b15 UPPERCASE base char
      out1 = nest.slot[k + 8'HAB];
      // b16 underscore AND internal spaces in a based literal
      out1 = nest.slot[k + 16'h ab_cd];
      // b17 comments inside the index
      out1 = nest.slot[k /* mid */ + /* here */ 9];
      // b18 the index broken over lines
      out1 = nest.slot[k
                       +
                       12];
      // b19 package localparam at the TRAILING site (no fold table)
      out1 = nest.slot[k + zed::PZ];
      // b20 package ENUM constant
      out1 = nest.slot[k + zed::GREEN];
      // b21 CLASS parameter operand
      out1 = nest.slot[k + CLSP];
      // b22 deep hier_path operand (3 components)
      out1 = nest.slot[k + mm.two.pk];
      // b23 hier_path operand that is itself a select
      out1 = nest.slot[k + mm.two.grid[1][2]];
      // b24 parens around a PLAIN identifier -- NOT an operation, must not move
      out1 = nest.slot[(k)];
      // b25 parens around an operation
      out1 = nest.slot[(k+1)];
      // b26 nested parens, mixed precedence
      out1 = nest.slot[((k+2)*(m-3))/4];
      // b27 shift by a hier_path
      out1 = nest.slot[k << mm.one.fld];
      // b28 ternary whose branches are calls
      out1 = nest.slot[k ? mz() : fz(m)];
      // b29 replication whose count is a package param
      out1 = nest.slot[{zed::QZ{k}}];
      // b30 replication of a hier_path
      out1 = nest.slot[{2{mm.one.fld}}];
      // b31 cast chain
      out1 = nest.slot[int'(byte'(k))];
      // b32 size cast
      out1 = nest.slot[4'(k)];
      // b33 concat of a range select and a bit select
      out1 = nest.slot[{wv[3:0], bw[1]}];
      // b34 power right-assoc
      out1 = nest.slot[k ** m ** 2];
      // b35 mixed logical/compare, no parens
      out1 = nest.slot[k > m && m < 3];
      // b36 modulo by a class method call
      out1 = nest.slot[k % nest.ng()];
      // b37 enum member bare
      out1 = nest.slot[k + AMBER];
      // b38 wildcard equality (no prettyPrint row)
      out1 = nest.slot[k ==? m];
      // b39 implication
      out1 = nest.slot[k -> m];
      // b40 nested concat inside inside-set
      out1 = nest.slot[k inside {{2{1'b1}}, 3}];
    endfunction

    // ---------- MID position and LVALUE ----------
    function void positions();
      // b41 MID rvalue through the operation index
      k = nest.slot[k + mm.one.fld].fld;
      // b42 MID lvalue
      nest.slot[k - mm.one.fld].fld = 3;
      // b43 TRAIL lvalue
      nest.slot[k * 2] = null;
      // b44 TRAIL lvalue with an empty-rendering operand
      nest.slot[k + mm.one.alt] = null;
      // b45 index in a condition
      if (nest.slot[k + 1] != null) k = 1;
      // b46 index as a call argument
      k = fz(nest.slot[k / 3].fld);
      // b47 2-D index MID: both dims operations
      k = mm.two.grid[k+1][m-1];
      // b48 2-D index TRAIL: first dim operation, second plain
      k = mm.two.grid[k+1][m];
      // b49 2-D index TRAIL: first plain, second operation
      k = mm.two.grid[k][m*2];
      // b50 2-D index with an empty-rendering operand in dim 2
      k = mm.two.grid[k][mm.one.fld + 1];
    endfunction

    // ---------- SITE 3: method-call receivers ----------
    function void recvs();
      // b51 plain
      k = list[k-1].tv();
      // b52 through this.
      k = this.list[k-1].tv();
      // b53 receiver with a hier_path operand
      k = list[k + mm.one.fld].tv();
      // b54 receiver, deep path, operation index
      k = mm.two.slot[k%3].tv();
      // b55 receiver with a ternary index
      k = list[k>0?k:0].tv();
      // b56 receiver, NON-operation index -- must NOT move
      k = list[k].tv();
      // b57 receiver, constant index -- must NOT move
      k = list[3].tv();
      // b58 receiver whose index is a cast (renders empty)
      k = list[int'(k)].tv();
      // b59 receiver with a concat index
      k = list[{2'b1, 2'b0}].tv();
      // b60 two selects in one receiver path
      k = mm.two.slot[k-1].tv();
    endfunction
  endclass
endpackage

module v92b1;
  import zed::*;
  typedef struct { int a; int b; } pr_t;
  parameter int MP = 5;
  localparam int LP = 3;

  nestor nn;
  deepy  dd;
  int    z, w;
  logic [15:0] vec;
  pr_t   pp;
  int    marr[4][4];

  initial begin
    // b61 module localparam operand in an operation
    nn.slot[z + LP] = null;
    // b62 module parameter operand
    nn.slot[z + MP] = null;
    // b63 struct member operand (a hier_path)
    nn.slot[z + pp.a] = null;
    // b64 range select of a module vector
    nn.slot[z + vec[7:0]] = null;
    // b65 indexed part select
    nn.slot[z + vec[2+:4]] = null;
    // b66 indexed part select, down
    nn.slot[z + vec[9-:4]] = null;
    // b67 2-D module array, range select on the second dim
    nn.slot[z + marr[1][3]] = null;
    // b68 hier_path from a module-level object, deep
    nn.slot[z + dd.two.pk] = null;
    // b69 concat with an empty-rendering operand in the middle
    nn.slot[{z, dd.one.fld, w}] = null;
    // b70 ternary with all three operands empty-rendering
    nn.slot[dd.one.fld ? dd.one.alt : dd.two.pk] = null;
  end
endmodule
