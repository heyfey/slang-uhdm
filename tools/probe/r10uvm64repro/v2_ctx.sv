// r10uvm64 VERIFIER arm v2 — THE CONTEXT CELLS b1/b2/b3 NEVER OPEN.
//
// The law keys on TWO things the arms only ever exercise at ONE point each:
//   * the SUBROUTINE is always a non-virtual, non-static, non-constructor
//     `function` of a class declared at $UNIT scope;
//   * the WINDOW is always a plain `if` (b1 adds one `case`), and the
//     NON-window control statements are only ever `while` and `for`.
// If golden's policy turns on any of that, the gate (`!classMethodNoBind` and
// nothing else) is either over- or under-firing where no arm can see it.
//
//   t<NN>  class TASK                      w<NN>  depth 2 == depth 2
//   x<NN>  casex / casez / case-inside     j<NN>  CASE-ITEM expression
//   k<NN>  do-while / repeat / forever / foreach / wait conditions
//   f<NN>  fork...join block               a<NN>  immediate assert condition
//   s<NN>  static / automatic block-local  n<NN>  constructor `new`
//   y<NN>  virtual method                  z<NN>  static class method
//   q<NN>  class declared in a PACKAGE     r<NN>  class declared in a MODULE

package v2p;
  class v2pc;
    int prop;
    function automatic int q1(input int farg);
      int r = 0;
      if (farg == 0) begin
        int q01_blkloc = 2;
        if (q01_blkloc == 3) r = 2;         // q01 CONDITION, depth 1, PKG class
        r = q01_blkloc;                     // q02 assignment RHS, depth 1
      end
      return r;
    endfunction
  endclass
endpackage

class v2c;
  int prop;
  int arr[3];

  function automatic int getid();
    return 42;
  endfunction

  // ------------------------------------------------------------ class TASK
  task automatic t1(input int farg, output int tr);
    tr = 0;
    if (farg == 0) begin
      int t01_blkloc = 2;
      if (t01_blkloc == 3) tr = 2;          // t01 CONDITION, depth 1, in a TASK
      tr = t01_blkloc;                      // t02 assignment RHS, depth 1
    end
  endtask

  // ------------------------------------------------------- depth 2 == 2
  function automatic int w1(input int farg);
    int r = 0;
    if (farg == 0) begin
      if (r == 0) begin
        int w01_blkloc = 2;
        if (w01_blkloc == 3) r = 2;         // w01 CONDITION, depth 2 == 2
        r = w01_blkloc;                     // w02 assignment RHS, depth 2
      end
    end
    return r;
  endfunction

  // ---------------------------------------- casex / casez / case-inside
  function automatic int x1(input int farg);
    int r = 0;
    if (farg == 0) begin
      int x01_blkloc = 2;
      casex (x01_blkloc)                    // x01 CASEX condition, depth 1
        3: r = 1;
        default: r = 2;
      endcase
      casez (x01_blkloc)                    // x02 CASEZ condition, depth 1
        3: r = 3;
        default: r = 4;
      endcase
      case (x01_blkloc) inside              // x03 CASE-INSIDE condition, d1
        [1:2]: r = 5;
        default: r = 6;
      endcase
    end
    return r;
  endfunction

  // --------------------------------------------- CASE-ITEM expressions
  function automatic int j1(input int farg);
    int r = 0;
    if (farg == 0) begin
      int j01_blkloc = 2;
      case (farg)
        j01_blkloc: r = 1;                  // j01 CASE-ITEM expr, depth 1
        default: r = 2;
      endcase
    end
    return r;
  endfunction

  // --------------------------- the NON-window control-statement spread
  function automatic int k1(input int farg);
    int r = 0;
    if (farg == 0) begin
      int k01_blkloc = 2;
      do r = r + 1; while (k01_blkloc == 3);   // k01 DO-WHILE condition, d1
      repeat (k01_blkloc) r = r + 1;           // k02 REPEAT count, depth 1
      foreach (arr[i]) r = r + k01_blkloc;     // k03 foreach BODY (depth 2)
    end
    return r;
  endfunction

  // ------------------------------------------------------ fork..join
  function automatic int f1(input int farg);
    int r = 0;
    if (farg == 0) begin
      int f01_blkloc = 2;
      if (f01_blkloc == 3) r = 1;           // f01 cond in the if-begin, d1
      fork
        begin
          int f02_forkloc = 4;
          if (f02_forkloc == 5) r = 2;      // f02 cond, FORK block local
        end
      join_none
    end
    return r;
  endfunction

  // ------------------------------------ immediate assert / static local
  function automatic int a1(input int farg);
    int r = 0;
    if (farg == 0) begin
      int a01_blkloc = 2;
      static int s01_stat = 3;
      assert (a01_blkloc == 3) r = 1;       // a01 ASSERT condition, depth 1
      if (s01_stat == 4) r = 2;             // s01 STATIC block-local in a cond
    end
    return r;
  endfunction

  // ------------------------------------------- constructor and virtual
  function new();
    int nfarg = 0;
    if (nfarg == 0) begin
      int n01_blkloc = 2;
      if (n01_blkloc == 3) prop = 2;        // n01 CONDITION in `new`, depth 1
      prop = n01_blkloc;                    // n02 assignment RHS, depth 1
    end
  endfunction

  virtual function int y1(input int farg);
    int r = 0;
    if (farg == 0) begin
      int y01_blkloc = 2;
      if (y01_blkloc == 3) r = 2;           // y01 CONDITION, VIRTUAL method
      r = y01_blkloc;                       // y02 assignment RHS, depth 1
    end
    return r;
  endfunction

  static function int z1(input int farg);
    int r = 0;
    if (farg == 0) begin
      int z01_blkloc = 2;
      if (z01_blkloc == 3) r = 2;           // z01 CONDITION, STATIC method
      r = z01_blkloc;                       // z02 assignment RHS, depth 1
    end
    return r;
  endfunction
endclass

module v2_top;
  // class declared INSIDE a module
  class v2mc;
    int prop;
    function automatic int r1(input int farg);
      int mr = 0;
      if (farg == 0) begin
        int r01_blkloc = 2;
        if (r01_blkloc == 3) mr = 2;        // r01 CONDITION, MODULE-scope class
        mr = r01_blkloc;                    // r02 assignment RHS, depth 1
      end
      return mr;
    endfunction
  endclass

  v2c h;
  v2mc mh;
  v2p::v2pc ph;
  int r;
  int tr;
  initial begin
    h = new();
    mh = new();
    ph = new();
    h.t1(0, tr);
    r = h.w1(0);
    r = h.x1(0);
    r = h.j1(0);
    r = h.k1(0);
    r = h.f1(0);
    r = h.a1(0);
    r = h.y1(0);
    r = v2c::z1(0);
    r = mh.r1(0);
    r = ph.q1(0);
  end
endmodule
