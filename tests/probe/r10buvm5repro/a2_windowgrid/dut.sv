// r10buvm5 arm a2 -- the SECOND half of the law: WHICH POSITIONS are binding
// WINDOWS for a `ref_var` local, and is the "same place" test a BLOCK test or a
// CONTROL-BODY-DEPTH test?
//
// a1 established: same block + call arg / condition operand / $cast arg BINDS;
// nested block NEVER binds; an ASSIGNMENT never binds even in the same block.
// The cells here separate the remaining candidates, and every one of them is a
// cell a rule could get wrong in a way the corpus would punish:
//
//   b08  a bare (no-begin) if BODY.  Surelog opens NO block for it, so a
//        BLOCK-keyed rule says BIND and a CTRL-DEPTH-keyed rule says BARE.
//   b09  decl in a nested block, read in THAT SAME nested block (uvm-1.2
//        m_set_cl_action's `t`) -- must BIND, or the fix destroys 23 good
//        bindings.
//   b11  a NAMED begin.
//   c*   the CONTROLS: an `int` local and a RESOLVED class-handle local read
//        from the very same positions.  If those bind where the ref_var does
//        not, the law is ref_var-specific and the gate must say so.
package q5;

  class box5 #(type T5 = int);
    T5 v5;
  endclass

  typedef box5 #(int) bi5_t;

  class plain5;
    int k5;
  endclass

  class own5;
    protected bi5_t hold5[$];
    protected int   nums5[$];

    extern function void b01_5(int m5);
    extern function int  b02_5(int m5);
    extern function void b03_5(int m5);
    extern function void b04_5(int m5);
    extern function void b06_5(int m5);
    extern function void b08_5(int m5);
    extern function void b09_5(int m5);
    extern function void b10_5(int m5);
    extern function void b11_5(int m5);
    extern function void c01_5(int m5);
    extern function void c02_5(int m5);
    extern function void c03_5(int m5);
    // the IN-CLASS twins of b01/b08/b09, so the fix can be shown not to move
    // what classMethodNoBind already governs
    function void i01_5(int m5);
      bi5_t v5;
      hold5.push_back(v5);
    endfunction
    function void i08_5(int m5);
      bi5_t v5;
      if (m5 == 0) hold5.push_back(v5);
    endfunction
  endclass

  function void sink5(bi5_t a5); endfunction
  function void isink5(int a5); endfunction
  function void psink5(plain5 a5); endfunction

  // b01 -- SYSTEM call argument that is NOT $cast, same block
  function void own5::b01_5(int m5);
    bi5_t v5;
    $display("%p", v5);
  endfunction

  // b02 -- RETURN expression, same block
  function int own5::b02_5(int m5);
    bi5_t v5;
    if (v5 == null) return 0;
    return m5;
  endfunction

  // b03 -- CASE condition, same block
  function void own5::b03_5(int m5);
    bi5_t v5;
    case (v5)
      null: m5 = 1;
      default: m5 = 2;
    endcase
  endfunction

  // b04 -- WHILE condition, same block
  function void own5::b04_5(int m5);
    bi5_t v5;
    while (v5 == null) m5 = m5 + 1;
  endfunction

  // b06 -- call argument that is an OPERATION, and a CONCATENATION operand
  function void own5::b06_5(int m5);
    bi5_t v5;
    int   n5;
    isink5((v5 == null) ? 1 : 0);
    nums5.push_back((v5 == null) ? 1 : 0);
  endfunction

  // b08 -- BARE (no begin) if body: no block opens, but the control depth rises
  function void own5::b08_5(int m5);
    bi5_t v5;
    if (m5 == 0) hold5.push_back(v5);
    if (m5 == 1) sink5(v5);
  endfunction

  // b09 -- decl AND read in the SAME nested block (must stay BOUND)
  function void own5::b09_5(int m5);
    if (m5 == 0) begin
      bi5_t v5;
      hold5.push_back(v5);
      if (v5 == null) m5 = 1;
    end
  endfunction

  // b10 -- decl in a nested block, read one block DEEPER
  function void own5::b10_5(int m5);
    if (m5 == 0) begin
      bi5_t v5;
      if (m5 == 0) begin
        hold5.push_back(v5);
      end
    end
  endfunction

  // b11 -- NAMED begin
  function void own5::b11_5(int m5);
    begin : nm5
      bi5_t v5;
      hold5.push_back(v5);
    end
  endfunction

  // ------------------------------------------------------------- CONTROLS
  // c01 -- an `int` local in the a1 P1/P2/P10 positions
  function void own5::c01_5(int m5);
    int i5;
    isink5(i5);                    // same block, call arg
    i5 = 3;                        // same block, assignment LHS
    if (m5 == 0) begin
      isink5(i5);                  // nested block, call arg
    end
  endfunction

  // c02 -- a RESOLVED class-handle local in the same three positions
  function void own5::c02_5(int m5);
    plain5 p5;
    psink5(p5);
    p5 = null;
    if (m5 == 0) begin
      psink5(p5);
    end
  endfunction

  // c03 -- a STRING local (the uvm_pkg set_inst_alias control: golden binds it
  // ACROSS blocks, which is what makes the law ref_var-specific)
  function void own5::c03_5(int m5);
    string s5;
    s5 = "x";
    if (m5 == 0) begin
      s5 = "y";
      isink5(s5.len());
    end
  endfunction

endpackage
