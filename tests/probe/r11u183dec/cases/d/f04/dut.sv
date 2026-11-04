package p;
class e; endclass
class c;
  extern function void f();
endclass
function void c::f();
   int n;
   int d[];
   foreach (d[k]) n = n + 1;
endfunction
endpackage
module top; endmodule
