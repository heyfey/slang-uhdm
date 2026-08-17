// vbuvm7 arm J — interface arrays, virtual interfaces, handle chains,
// multi-line lvalues and MACRO-expanded lvalues.
`define BUMPJ(a,i) a[i].used++
typedef struct { int used; } stJ_t;
interface ifJ; stJ_t s; int cnt; endinterface
class leafJ; int used; endclass
class midJ;  leafJ h; endclass
class holdJ;
  midJ  mq[$];
  stJ_t q[$];
  int   i;
  function void f();
    i = 0;
    mq[i].h.used++;            // J1 handle chain: select, member(handle), member
    q[i]
      .used++;                 // J2 MULTI-LINE lvalue
    `BUMPJ(q, i)               // J3 MACRO-expanded lvalue
    ;
  endfunction
endclass
module topJ;
  ifJ ifa[2]();
  virtual ifJ vifs[2];
  initial begin
    ifa[0].cnt++;              // J4 INTERFACE ARRAY element member
    ifa[1].s.used++;           // J5 interface array element, nested member
  end
endmodule
