// § foreachFlatLocalRefTs238
module top;
  function automatic int f;
    string vs[$];
    int a[4];
    begin
      foreach (vs[i]) f++;
      foreach (a[j]) f += a[j];
    end
  endfunction
  task automatic t;
    int q[$];
    foreach (q[k]) q[k] = 1;
  endtask
  int r;
  initial r = f();
endmodule
