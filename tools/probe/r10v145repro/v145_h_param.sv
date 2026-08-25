// r10v145 arm H -- THE TASK-BODY BLOCK-ITEM *BREAK*.
// `compileTask` (Surelog CompileStmt.cpp:2010-2028) advances past tf_item
// declarations only while each one is a tf_port_declaration or a
// block_item_declaration whose child IS a paData_declaration; anything else
// (a parameter / localparam declaration) BREAKS the advance, so the statement
// walk starts AT that item and every declaration from there on is compiled by
// compileDataDeclaration -- i.e. it HOISTS.  `compileFunction` (:2425-2470)
// has no such break: it handles parameters inline and keeps advancing.
// MEASUREMENT ONLY.
module mh145v;

  // --- TASK, body io, decl BEFORE and AFTER the parameter ---
  task h_ba145v;
    input int p;
    int pre = 1;
    parameter PP = 7;
    int post = 2;
    $display(pre, post, p, PP);
    $display(pre);
  endtask

  // --- TASK, body io, localparam ---
  task h_lp145v;
    input int p;
    localparam LP = 7;
    int a = 1;
    $display(a, p, LP);
    $display(a);
  endtask

  // --- TASK, body io, parameter, TWO statements ---
  task h_p2145v;
    input int p;
    parameter PP = 7;
    int a = 1;
    int b = 2;
    $display(a, b, p, PP);
    $display(a);
  endtask

  // --- TASK, body io, parameter LAST (after all decls) ---
  task h_plast145v;
    input int p;
    int a = 1;
    int b = 2;
    parameter PP = 7;
    $display(a, b, p, PP);
    $display(a);
  endtask

  // --- TASK, body io, a TYPEDEF (a data_declaration: NO break expected) ---
  task h_td145v;
    input int p;
    typedef int th145v_t;
    th145v_t a = 1;
    $display(a, p);
    $display(a);
  endtask

  // --- control: TASK, body io, NO parameter ---
  task h_noparam145v;
    input int p;
    int a = 1;
    int b = 2;
    $display(a, b, p);
    $display(a);
  endtask

  // --- FUNCTION, paren-less, decl BEFORE and AFTER a parameter ---
  function void hf_ba145v;
    int pre = 1;
    parameter QQ = 5;
    int post = 2;
    $display(pre, post, QQ);
    $display(pre);
  endfunction

  // --- BLOCK-ITEM task twin with a parameter ---
  task hb_ba145v(input int p);
    int pre = 1;
    parameter PP = 7;
    int post = 2;
    $display(pre, post, p, PP);
    $display(pre);
  endtask

endmodule
