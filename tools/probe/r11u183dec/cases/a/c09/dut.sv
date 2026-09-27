package p;
class e; endclass
class c;
  
  extern function void f();
endclass
function void c::f();
   int q[$:7];
   int idx;
   idx = 1;
endfunction
endpackage
module top; endmodule
