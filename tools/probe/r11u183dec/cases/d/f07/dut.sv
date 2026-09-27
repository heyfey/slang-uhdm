package p;
class e; endclass
class c;
  extern function void f();
endclass
function void c::f();
   int n;
   int s[2][3];
   foreach (s[i,j]) n = n + 1;
endfunction
endpackage
module top; endmodule
