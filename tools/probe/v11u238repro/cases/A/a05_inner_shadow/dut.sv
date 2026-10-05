// § cloneForIncBindsHomeVar238
// an inner block re-declaring the loop variable's name (its references must keep the inner local),
// a sibling loop re-using the name, the loop variable as a call argument and inside an index
package p;
  function int sq(int x); return x * x; endfunction
  function int h(int n);
    int a[8];
    int acc;
    acc = 0;
    for (int i = 0; i < n; i++) begin
      a[sq(i) % 8] = i;
      begin
        int i;
        i = 5;
        acc += i;
      end
      acc += a[i];
    end
    for (int i = n; i > 0; i--) acc -= i;
    return acc;
  endfunction
endpackage
package q;
  import p::*;
  function int qh(int n); return h(n); endfunction
endpackage
module top;
  int r;
  initial r = q::qh(3);
endmodule
