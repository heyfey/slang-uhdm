package p;
class e; endclass
class c;
  extern function void f(bit m[e]);
endclass
function void c::f(bit m[e]);
   int idx;
   idx = 1;
endfunction
endpackage
module top; endmodule
