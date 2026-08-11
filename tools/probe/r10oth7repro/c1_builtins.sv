// r10oth7 arm 1 — HALF A: which class_typespec loses its vpiClassDefn.
// Every cell is a `class_typespec` position; the question per cell is whether
// golden's object carries vpiClassDefn, and whether ours does.
// BUILT-IN classes (mailbox/semaphore/process) vs USER classes, in the SAME
// positions, so "built-in vs user-declared" is an ARM, not an assumption.
// Run WITH builtins (ctarm.sh default) — `-nobuiltin` deletes half the cells.

class u_cls;                       // a plain USER class
  int f;
endclass

class u_par #(type T = int);       // a PARAMETERIZED user class
  T g;
endclass

package pk;
  class p_cls;                     // a class declared in a PACKAGE
    int h;
  endclass
endpackage

typedef u_cls u_alias_t;           // a user class reached through a TYPEDEF

class holder;
  // a1..a3: BUILT-IN class handles as class PROPERTIES.
  mailbox   a1_mb;
  semaphore a2_sem;
  process   a3_proc;
  // a4: an EXPLICITLY PARAMETERIZED built-in handle.
  mailbox #(int) a4_mbi;
  // a5: a USER class handle, same position — the CONTROL for a1.
  u_cls     a5_user;
  // a6: the same user class through a TYPEDEF.
  u_alias_t a6_alias;
  // a7: a parameterized USER class handle.
  u_par #(int) a7_par;
  // a8: a class declared in a PACKAGE, scope-qualified.
  pk::p_cls a8_pkg;

  // a9..a11: the same handles as METHOD FORMALS (io_decl position).
  function new(mailbox a9_mb, u_cls a10_user, pk::p_cls a11_pkg);
    this.a1_mb = a9_mb;
    this.a5_user = a10_user;
    this.a8_pkg = a11_pkg;
  endfunction

  // a12..a14: the same handles as METHOD BODY LOCALS.
  task t();
    mailbox   a12_mb;
    u_cls     a13_user;
    pk::p_cls a14_pkg;
    a12_mb = new();
    a13_user = new();
    a14_pkg = new();
  endtask
endclass

module m_top;
  // a15..a17: the same handles at MODULE scope.
  mailbox a15_mb;
  u_cls   a16_user;
  holder  a17_holder;
  initial begin
    a15_mb = new();
    a16_user = new();
    a17_holder = new(a15_mb, a16_user, null);
  end
endmodule
