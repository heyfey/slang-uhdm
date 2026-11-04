// § cloneForIncBindsHomeVar238
package p;
  task automatic tk(input int n, output int o);
    o = 0;
    for (int i = 0; i < n; i++) begin
      for (int j = i; j >= 0; j--) o += j;
      o++;
    end
  endtask
  function automatic int f(int a[4]);
    foreach (a[k]) for (int m = 0; m < k; m += 1) f += a[m];
    for (int unsigned u = 1; u < 8; u <<= 1) f++;
    for (int b = 0; b < 3; b = b + 1) f--;
  endfunction
endpackage
package q;
  import p::*;
  task automatic qt(output int o);
    tk(3, o);
  endtask
  function automatic int qf();
    int a[4] = '{1, 2, 3, 4};
    return f(a);
  endfunction
endpackage
module top;
  import q::*;
  int x, y;
  initial begin qt(x); y = qf(); end
endmodule
