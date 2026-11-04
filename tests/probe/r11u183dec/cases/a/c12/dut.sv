package p;
class e; endclass
class c;
  
  extern function void f();
endclass
function void c::f();
   bit [3:0] v;
   int idx;
   idx = 1;
endfunction
endpackage
module top; endmodule
