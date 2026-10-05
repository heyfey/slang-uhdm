// § cloneForIncBindsHomeVar238
// an inner block re-declaring the loop variable's name, a loop variable as a call argument inside an index,
// the loop variable read after a nested for with the same name in a sibling loop
package p;
  function automatic int sq(int x); return x * x; endfunction
  function automatic int h(int n);
    int a[8];
    int acc = 0;
    for (int i = 0; i < n; i++) begin
      int j;
      j = i;
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
  function automatic int qh(int n); return h(n); endfunction
endpackage
module top(output int o);
  assign o = q::qh(3);
endmodule
