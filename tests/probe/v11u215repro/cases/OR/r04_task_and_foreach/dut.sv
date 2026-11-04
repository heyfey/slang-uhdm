// § opIdxRecvElemFollowsPath215 — an operation index inside a task, a foreach body, a nested function call argument and a package free function
package p;
  class fld;
    function int get(); return 0; endfunction
    function void put(int x); endfunction
  endclass
  function automatic int h(int x); return x; endfunction
  class reg_c;
    fld fields[$];
    task t(int i);
      fields[i+1].put(h(fields[i-1].get()));
    endtask
    function void f();
      foreach (fields[i]) if (i > 0) fields[i-1].put(i);
    endfunction
  endclass
  function automatic int free_f(fld fs[$], int i);
    return fs[i-1].get() + fs[i].get();
  endfunction
endpackage
module m;
endmodule
