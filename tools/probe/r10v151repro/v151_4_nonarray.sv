// r10v151 (VERIFIER) arm 4 — THE MUST-STAY CONTROL: built-in methods that are
// NOT array manipulation.  Every one of these keeps the `method_func_call` +
// `vpiPrefix` shape (§ 14 and the standing builtin laws), in statement and in
// expression position, with and without arguments.  MEASUREMENT ONLY.
// LHS is always golden (Surelog), RHS always ours.
package Npk4;
  typedef enum { RED4, AMBER4, GREEN4 } Hue4;
  class Cell4;
    rand int rv;
    int      cv;
    constraint cc4 { rv > 0; }
  endclass
  class Host4;
    int    dq[$];
    int    am4[string];
    string sname;
    Cell4  cel;
    Hue4   hue;
    task run4;
      int    j;
      string s2;
      Cell4  other;
      // ---- QUEUE / DYNAMIC / ASSOCIATIVE non-manipulation methods ----
      dq.push_back(7);
      dq.push_front(8);
      dq.insert(0, 9);
      dq.delete(0);
      dq.pop_front();
      dq.pop_back();
      j = dq.size();
      am4.delete("k4");
      j = am4.num();
      j = am4.exists("k4");
      am4.first(s2);
      am4.next(s2);
      am4.last(s2);
      // ---- STRING methods ----
      j  = sname.len();
      s2 = sname.substr(0, 2);
      sname.itoa(11);
      s2 = sname.toupper();
      j  = sname.atoi();
      // ---- ENUM methods ----
      s2 = hue.name();
      hue = hue.next();
      j = hue.num();
      // ---- CLASS non-array builtins ----
      cel.constraint_mode(0);
      cel.rand_mode(1);
      cel.cc4.constraint_mode(1);
      j = cel.randomize();
      j = cel.randomize(rv);
      other = cel;
      // ---- and their EXPRESSION twins ----
      if (dq.size() > 0) j = 1;
      $display("%0d %s", am4.num(), sname.substr(1, 1));
      j = dq.size() + am4.num();
    endtask
  endclass
endpackage
