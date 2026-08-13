// r10uvm69repro/a1_type.sv — THE RETURN-TYPE AXIS.
//
// Every function here calls a METHOD ON ITS OWN RETURN VARIABLE.  The corpus
// says golden COLLAPSES some of these to a `func_call` named by the receiver and
// bound to the enclosing function, and KEEPS the method shape for others:
//
//   COLLAPSE  open_recorder.m_do_open(...)   class handle, USER method
//   COLLAPSE  myFunc1.push_back('{i,i})      queue,        built-in  (CrossFunc)
//   KEEP      index_string.itoa(index)       string,       built-in
//   KEEP      uvm_instance_scope.substr(...) string,       built-in
//   KEEP      uvm_instance_scope.len()       string,       built-in
//
// The two candidate discriminators fit that corpus population IDENTICALLY:
//   (T) the receiver's TYPE is `string`
//   (M) the METHOD is a string built-in
// They cannot be separated on the corpus because every string cell there uses a
// string method.  This arm separates them by putting NON-string built-in
// containers (queue, dynamic array, associative array, enum) beside string, all
// on a return-name receiver, in one database.
//
// Cells are named in comments as <ROW><COL> so the README grid can quote them.
package p1;

  typedef int qT[$];
  typedef int dT[];
  typedef int aT[string];

  typedef enum { E0, E1 } eT;

  class c1;
    int v;
    function void touch(int x); v = x; endfunction
    function int  peek();       return v; endfunction
  endclass

  // A1 — STRING return, built-in string methods, STATEMENT position.
  //      Corpus twin: uvm_printer::index_string (`index_string.itoa(index);`).
  function string f_str_stmt(int i);
    f_str_stmt.itoa(i);          // A1
  endfunction

  // A2 — STRING return, built-in string method, EXPRESSION position.
  //      Corpus twin: uvm_instance_scope (`= uvm_instance_scope.substr(0,pos)`).
  function string f_str_expr(int p);
    f_str_expr = "abcdef";
    f_str_expr = f_str_expr.substr(0, p);   // A2
  endfunction

  // A3 — STRING return, no-arg built-in, EXPRESSION position.
  //      Corpus twin: `pos = uvm_instance_scope.len()-1;`
  function int f_str_len();
    string s;
    s = "abc";
    f_str_len = s.len();          // A3  (ordinary local receiver: CONTROL)
  endfunction

  function string f_str_len2(int unused);
    int pos;
    f_str_len2 = "abcd";
    pos = f_str_len2.len() - 1;   // A4  (return-name receiver)
  endfunction

  // B1 — QUEUE return, built-in queue method, STATEMENT position.
  //      Corpus twin: CrossFunc `myFunc1.push_back('{i,i});` -> COLLAPSES.
  function qT f_q_stmt(int n);
    f_q_stmt.push_back(n);        // B1
  endfunction

  // B2 — QUEUE return, built-in queue method, EXPRESSION position.
  function int f_q_expr(int n);
    qT q;
    q.push_back(n);
    f_q_expr = q.size();          // B2 (ordinary local: CONTROL)
  endfunction

  function qT f_q_expr2(int n);
    int k;
    f_q_expr2.push_back(n);
    k = f_q_expr2.size();         // B3 (return-name receiver, EXPRESSION)
  endfunction

  // C1 — DYNAMIC ARRAY return, built-in method, STATEMENT position.
  function dT f_d_stmt(int n);
    f_d_stmt = new[n];
    f_d_stmt.delete();            // C1
  endfunction

  // C2 — DYNAMIC ARRAY return, built-in, EXPRESSION position.
  function dT f_d_expr(int n);
    int k;
    f_d_expr = new[n];
    k = f_d_expr.size();          // C2
  endfunction

  // D1 — ASSOCIATIVE ARRAY return, built-in, STATEMENT position.
  function aT f_a_stmt(int n);
    f_a_stmt["k"] = n;
    f_a_stmt.delete("k");         // D1
  endfunction

  // D2 — ASSOCIATIVE ARRAY return, built-in, EXPRESSION position.
  function aT f_a_expr(int n);
    int k;
    f_a_expr["k"] = n;
    k = f_a_expr.num();           // D2
  endfunction

  // E1 — CLASS HANDLE return, USER method, STATEMENT position.
  //      Corpus twin: THE HEAD, `open_recorder.m_do_open(this,...)`.
  function c1 f_c_stmt(int n);
    f_c_stmt = new();
    f_c_stmt.touch(n);            // E1
  endfunction

  // E2 — CLASS HANDLE return, USER method, EXPRESSION position.
  function c1 f_c_expr(int n);
    int k;
    f_c_expr = new();
    k = f_c_expr.peek();          // E2
  endfunction

  // F1 — ENUM return, built-in enum method, EXPRESSION position.
  function string f_e_expr(eT e);
    eT t;
    t = e;
    f_e_expr = t.name();          // F1 (ordinary local: CONTROL)
  endfunction

  function eT f_e_expr2(int n);
    string s;
    f_e_expr2 = E1;
    s = f_e_expr2.name();         // F2 (return-name receiver)
  endfunction

endpackage

module a1_top;
  import p1::*;
  string  s1;
  int     i1;
  initial begin
    s1 = f_str_stmt(7);
    s1 = f_str_expr(3);
    i1 = f_str_len();
  end
endmodule
