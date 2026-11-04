package p;
class e; endclass
class c;
  function void f();
   int n;
   bit m[e];
   foreach (m[k]) n = n + 1;
  endfunction
endclass
endpackage
module top; endmodule
