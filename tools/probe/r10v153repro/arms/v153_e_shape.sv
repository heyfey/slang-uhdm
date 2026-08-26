// r10v153 arm E — MORE SHAPES for the colliding property: a foreach body, a
// fork, a named block, a do/while, a repeat, a $cast argument, a queue and an
// associative array, a receiver that is an ARRAY ELEMENT, a two-element
// hier_path.  LHS is always golden.
package pve153;

  class Kve153;
    int fe;
    Kve153 nxt;
    function void ke(); endfunction
  endclass

  int    z_each;
  int    z_fork;
  int    z_name;
  int    z_do;
  int    z_rep;
  int    z_cast;
  int    z_q[$];
  int    z_aa[string];
  Kve153 z_arr[2];
  Kve153 z_deep;

  class Cve153;
    int    z_each;
    int    z_fork;
    int    z_name;
    int    z_do;
    int    z_rep;
    int    z_cast;
    int    z_q[$];
    int    z_aa[string];
    Kve153 z_arr[2];
    Kve153 z_deep;
    int    z_list[3];
    extern function void me153(int p);
  endclass

  function void Cve153::me153(int p);
    foreach (z_list[i])
      z_each = i;                   // 1 foreach BODY
    fork
      z_fork = p;                   // 2 inside a FORK
    join_none
    begin : nb153
      z_name = p;                   // 3 a NAMED block
    end
    do z_do = p; while (z_do < 0);  // 4 a do/while body
    repeat (2) z_rep = p;           // 5 a repeat body
    void'($cast(z_cast, p));        // 6 a $cast argument
    z_q.push_back(p);               // 7 a QUEUE receiver
    z_aa["k"] = p;                  // 8 an ASSOC-ARRAY lvalue
    z_arr[0].ke();                  // 9 an ARRAY-ELEMENT receiver
    z_deep.nxt.fe = p;              // 10 a TWO-element hier_path
  endfunction

endpackage
