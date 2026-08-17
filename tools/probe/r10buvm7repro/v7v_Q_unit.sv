// vbuvm7 arm Q — $unit-scope class out-of-body method (no home package) and
// a $root-qualified lvalue.
typedef struct { int used; } stQ_t;
class cQ;
  stQ_t arr[4];
  extern function void f();
endclass
function void cQ::f();
  arr[1].used++;             // Q1 $unit-scope class: no home PACKAGE
endfunction
module subQ; stQ_t sarr[4]; endmodule
module topQ;
  subQ u();
  cQ h;
  stQ_t marr[4];
  initial begin
    h = new(); h.f();
    $root.topQ.marr[1].used++;   // Q2 $root-qualified
    marr[2].used++;              // Q3 control
  end
endmodule
