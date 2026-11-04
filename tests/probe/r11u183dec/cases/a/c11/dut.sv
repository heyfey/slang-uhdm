package p;
class e; endclass
class c;
  typedef e qe[$];
  extern function void f();
endclass
function void c::f();
   qe r;
   int idx;
   idx = 1;
endfunction
endpackage
module top; endmodule
