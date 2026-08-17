// r10sd9 GRID CELL g1 — THE CORE CELL, and every control that belongs next to
// it.  One class, one package, eight properties: the SCALAR and the ARRAY
// spelling of a class-handle typedef, an int typedef, a struct typedef, a BARE
// class handle and a CLASS-NESTED typedef.  The law is "the array element binds
// what the scalar binds", so both halves are scored on every kind in one dump.
package px;
  class kx;
    int xx;
  endclass
  typedef kx tcls;
  typedef int tint;
  typedef struct { int a; int b; } tstr;
  class cm;
    tcls  s_cls;
    tcls  a_cls [string];
    tcls  d_cls [];
    tint  s_int;
    tint  a_int [string];
    tstr  s_str;
    tstr  a_str [string];
    kx    a_bare [string];
    typedef kx this_t;
    this_t a_nest [string];
  endclass
endpackage
module topx;
  px::cm hx;
endmodule
