// r10v157 ARM E — SURELOG'S BODY-ITEM COUNT, ATTACKED.  SITE 3 fires only when
// `subroutineBodyItemCount157(sub) == 1`.  Every cell here is a body item that
// slang models WITHOUT a member of the four counted kinds and WITHOUT a body
// statement — if Surelog counts it, our count is one too low and the listing
// lands on the task_func where golden put it on a synthesised `begin`.
// MEASUREMENT ONLY.
package Kiln157;
  // (1) the CALIBRATION cell: exactly one item, both counts agree
  task automatic bakeOne157; typedef bit [3:0] emberOne157; endtask

  // (2) a LET declaration next to the typedef — a block_item_declaration that
  //     is not a variable, not a parameter and not a typedef
  task automatic bakeLet157;
    typedef bit [3:0] emberLet157;
    let warmLet157(x) = x + 1;
  endtask

  // (3) an explicit EMPTY begin..end next to the typedef
  task automatic bakeEmpty157;
    typedef bit [3:0] emberEmpty157;
    begin end
  endtask

  // (4) a bare semicolon (null statement) next to the typedef
  task automatic bakeNull157;
    typedef bit [3:0] emberNull157;
    ;
  endtask

  // (5) TWO typedefs and nothing else
  task automatic bakeTwo157;
    typedef bit [3:0] emberTwoA157;
    typedef bit [5:0] emberTwoB157;
  endtask

  // (6) a task-scope PARAMETER next to the typedef
  task automatic bakeParam157;
    parameter int GLOW157 = 2;
    typedef bit [GLOW157:0] emberParam157;
  endtask

  // (7) a LOCAL next to the typedef
  task automatic bakeLocal157;
    typedef bit [3:0] emberLocal157;
    emberLocal157 emberHold157;
  endtask

  // (8) a STATIC lifetime spelling with a sole typedef
  task static bakeStatic157; typedef bit [3:0] emberStatic157; endtask

  // (9) a sole typedef whose target is a NAME (nothing is pushed anywhere,
  //     so the task_func must stay null on BOTH sides)
  typedef bit [3:0] emberFar157;
  task automatic bakeAlias157; typedef emberFar157 emberNear157; endtask

  // (10) a sole typedef of a DECLINED form (enum) — this law lists nothing
  task automatic bakeEnum157; typedef enum bit {COOL157, HOT157} emberEnum157; endtask

  // (11) a FORWARD typedef and its definition, nothing else
  task automatic bakeFwd157;
    typedef emberFwd157;
    typedef bit [3:0] emberFwd157;
  endtask

  // (12) a function returning int whose only item is a typedef.  The `void`
  //      spelling SEGFAULTS Surelog (recorded by r10uvm157); this arm records
  //      its own rc so a crash can never read as a result.
  function int bakeFnOne157; typedef bit [3:0] emberFn157; endfunction
endpackage
