package p;
class e; endclass
class c;
  typedef e qe[$];
  extern function qe f();
endclass
function qe c::f();
   
   int idx;
   idx = 1;
endfunction
endpackage
module top; endmodule
