package p;
class e; endclass
class c;
  
  extern function void f();
endclass
function void c::f();
   int s[3:0];
   int idx;
   idx = 1;
endfunction
endpackage
module top; endmodule
