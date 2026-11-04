package p;
class e; endclass
class c;
  bit m[e];
  extern function void f();
endclass
function void c::f();
   int n;
   foreach (m[k]) n = n + 1;
endfunction
endpackage
module top; endmodule
