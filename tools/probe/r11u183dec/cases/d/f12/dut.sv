package p;
class e; endclass
class c;
  extern function void f();
endclass
function void c::f();
   int n;
   begin
     bit m[e];
     foreach (m[k]) n = n + 1;
   end
endfunction
endpackage
module top; endmodule
