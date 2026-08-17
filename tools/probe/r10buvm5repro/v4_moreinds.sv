// vbuvm5 ADVERSARIAL arm v4 -- the REST of the condition family, after v3
// showed that golden's window includes CASE ITEM EXPRESSIONS and IMMEDIATE
// ASSERTION conditions, neither of which the patch raises.
package qy;

  class boxy #(type Ty = int);
    Ty vy;
  endclass
  typedef boxy #(int) biy_t;

  class owny;
    typedef logic [7:0] by_t;
    protected int numsy[$];
    protected int my;

    extern function void y01y(int ny);
    extern function void y02y(int ny);
    extern function void y03y(int ny);
    extern function void y04y(int ny);
    extern function void y05y(int ny);
    extern function void y06y(int ny);
    extern function void y07y(int ny);
    extern task         y08y(int ny);
    extern task         y09y(int ny);
    extern function void y10y(int ny);
  endclass

  function void sinky(biy_t ay); endfunction

  // y01 -- ASSUME immediate
  function void owny::y01y(int ny);
    biy_t vy;
    assume (vy != null) numsy.push_back(1);
  endfunction

  // y02 -- COVER immediate
  function void owny::y02y(int ny);
    biy_t vy;
    cover (vy != null) numsy.push_back(1);
  endfunction

  // y03 -- ASSERT with an ELSE clause
  function void owny::y03y(int ny);
    biy_t vy;
    assert (vy != null) numsy.push_back(1); else numsy.push_back(2);
  endfunction

  // y04 -- ASSERT condition one control body DEEPER than the decl
  function void owny::y04y(int ny);
    biy_t vy;
    if (ny == 0) begin
      assert (vy != null) numsy.push_back(1);
    end
  endfunction

  // y05 -- ASSERT condition whose decl is in that same block (d1 == d1)
  function void owny::y05y(int ny);
    if (ny == 0) begin
      biy_t vy;
      assert (vy != null) numsy.push_back(1);
    end
  endfunction

  // y06 -- CASE ... INSIDE item expression
  function void owny::y06y(int ny);
    by_t vy;
    by_t uy;
    case (vy) inside
      uy: numsy.push_back(1);
      default: numsy.push_back(2);
    endcase
  endfunction

  // y07 -- the ref_var inside a nested TERNARY inside an if CONDITION
  function void owny::y07y(int ny);
    biy_t vy;
    if ((ny == 0 ? vy : null) == null) numsy.push_back(1);
  endfunction

  // y08 -- WAIT condition (task-only)
  task owny::y08y(int ny);
    by_t vy;
    wait (vy == 0);
  endtask

  // y09 -- an EVENT CONTROL naming the ref_var (task-only)
  task owny::y09y(int ny);
    by_t vy;
    @(vy) numsy.push_back(1);
  endtask

  // y10 -- assert inside a case item at the decl's own depth
  function void owny::y10y(int ny);
    biy_t vy;
    case (ny)
      0: assert (vy != null) numsy.push_back(1);
      default: numsy.push_back(2);
    endcase
  endfunction

endpackage
