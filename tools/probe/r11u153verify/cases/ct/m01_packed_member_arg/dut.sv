// § classTdStructMemberPkgPath146
package p;
class c;
  typedef struct packed { logic [3:0] n; logic v; } acc_t;
  function automatic int get(acc_t a); return a.n; endfunction
endclass
endpackage
