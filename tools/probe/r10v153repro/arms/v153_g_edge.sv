// r10v153 arm G — EDGES: a NESTED class's out-of-body method, a property
// colliding with a package PARAMETER (not a variable), a property read inside
// a CONSTRAINT and inside `randomize() with`, an out-of-body STATIC method,
// and a property whose name collides with a package TYPEDEF.  LHS is golden.
package pvg153;

  parameter int g_par = 7;              // a package PARAMETER, not a variable
  typedef int   g_td;                   // a package TYPEDEF
  int           g_var;                  // a real package variable
  int           g_stat;
  int           g_rand;
  int           g_cons;

  class Ogd153;
    int g_var;
    class Igd153;                       // a NESTED class (in-body method:
      int g_var;                        // slang rejects `A::B::m` definitions)
      function void nm153(int p);
        g_var = p;
      endfunction
    endclass
    extern function void om153(int p);
  endclass

  function void Ogd153::om153(int p);
    g_var = p;                          // outer OOB method
  endfunction

  class Cgd153;
    int       g_par;                    // collides with a package PARAMETER
    int       g_td;                     // collides with a package TYPEDEF
    static int g_stat;
    rand int  g_rand;
    int       g_cons;
    constraint c153 { g_rand < g_cons; }   // inside a CONSTRAINT
    extern function void mg153(int p);
    extern static function void sg153(int p);
  endclass

  function void Cgd153::mg153(int p);
    g_par = p;                          // package PARAMETER of that name
    g_td  = p;                          // package TYPEDEF of that name
    g_cons = p;
    void'(this.randomize() with { g_rand > g_cons; });
  endfunction

  function void Cgd153::sg153(int p);
    g_stat = p;                         // an out-of-body STATIC method
  endfunction

endpackage
