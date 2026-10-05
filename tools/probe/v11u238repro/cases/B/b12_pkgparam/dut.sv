// § foreachFlatLocalRefTs238
// a paren-less package function's local beside a same-named package PARAMETER
package p;
  parameter int vals = 3;
  function void f;
    static string vals[$];
    string t[$];
    foreach (vals[i]) t.push_back(vals[i]);
  endfunction
endpackage
module top;
endmodule
