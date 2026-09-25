// § classTdStructMemberPkgPath146
package p;
class t;
  typedef struct { int unsigned n; } acc_t;
endclass
class c;
  function void f();
    t::acc_t r;
    r.n = 1;
  endfunction
endclass
endpackage
