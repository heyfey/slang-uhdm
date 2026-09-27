package p;
class e; endclass
class c;
  extern function void f();
endclass
function void c::f();
   int n;
   int s[4];
   foreach (s[k]) n = n + 1;
endfunction
endpackage
module top; endmodule
