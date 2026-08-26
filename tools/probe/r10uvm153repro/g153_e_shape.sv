// r10uvm153 arm E — THE SHAPES.  Which class member, which method flavour,
// which enclosing statement.  Every cell is a name that collides with an entry
// of the package's `Variables()` listing except where the comment says
// otherwise.  LHS is golden (Surelog).
package pe153;

  parameter int e_param = 3;    // a package PARAMETER, NOT in Variables()
  int    e_int;
  int    e_stat;
  int    e_base;
  int    e_virt;
  int    e_fork;
  int    e_each;
  int    e_par;
  string e_str;

  class Be153;                  // a BASE class: its property is INHERITED
    int e_base;
  endclass

  class Ee153 extends Be153;
    static int e_stat;          // a STATIC property
    int        e_int;
    int        e_virt;
    int        e_fork;
    int        e_each;
    int        e_param;         // collides with a package PARAMETER only
    extern function void ee153(int p);
    extern virtual function void ev153(int p);
    extern static function void es153(int p);
  endclass

  function void Ee153::ee153(int p);
    int e_arr[3];
    e_int  = p;                 // 1 an ordinary property
    e_base = p;                 // 2 an INHERITED property
    e_stat = p;                 // 3 a STATIC property
    e_param = p;                // 4 collides with a package PARAMETER only
    fork
      e_fork = p;               // 5 inside a FORK
    join_none
    foreach (e_arr[i])
      e_each = i;               // 6 inside a FOREACH body
  endfunction

  function void Ee153::ev153(int p);
    e_virt = p;                 // 7 a VIRTUAL method
  endfunction

  function void Ee153::es153(int p);
    e_stat = p;                 // 8 a STATIC method
  endfunction

  // A PARAMETERIZED class: its out-of-body method's home is still the package.
  class Pe153 #(int W = 1);
    int e_par;
    extern function void pe153(int p);
  endclass
  function void Pe153::pe153(int p);
    e_par = p;                  // 9 a parameterized class
  endfunction

  // The class's own method DECLARED out of body but named with the class scope
  // inside a nested named block.
  class Ne153;
    string e_str;
    extern function void ne153(int p);
  endclass
  function void Ne153::ne153(int p);
    begin : nb153
      e_str = "n";              // 10 a NAMED block
    end
  endfunction

endpackage
