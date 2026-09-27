class e; endclass
class c;
  extern function void f();
endclass
function void c::f();
   bit m[e];
   int idx;
   idx = 1;
endfunction
module top; endmodule
