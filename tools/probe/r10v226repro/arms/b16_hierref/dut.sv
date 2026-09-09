// v226 b16 — hard references from an uninstantiated interface's process:
// a hierarchical name, a class handle and its method, a virtual interface, a
// struct/union member, an array select and a $unit-scope name.  Robustness as
// much as law: none of these may segfault or mint.
package bh_pkg;
  class C;
    int f;
    function automatic int g(); return f; endfunction
  endclass
endpackage

interface bh_other;
  int shared_n;
endinterface

interface bh_if;
  import bh_pkg::*;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } s_t;
  s_t   sv;
  int   arr [0:3];
  C     h;
  int   n;

  initial begin
    h = new();
    n = h.g();                 // class method through a handle
    n = h.f;                   // class property
    sv.hi = 4'h1;              // struct member
    n = arr[2];                // array select
  end

  always_comb n = sv.lo;
endinterface
