// § foreachIfaceClassAbstain417v
package p;
  interface class b;
    pure virtual function int f();
  endclass
  function automatic int g();
    int b[2];
    int n;
    foreach (b[i]) n += i;
    return n;
  endfunction
endpackage
module top;
endmodule
