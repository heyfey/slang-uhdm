package p;
class e; endclass
typedef int ti;
class c;
  extern function void f();
endclass
function void c::f();
   bit m[e][ti];
   int idx;
   idx = 1;
endfunction
endpackage
module top; endmodule
