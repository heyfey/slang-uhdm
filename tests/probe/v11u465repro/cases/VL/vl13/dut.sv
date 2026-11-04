// § cloneLvSharesHomeUnitTs465
// a package function over a dynamic-array formal int arr[]
package h;
  function int g(int arr[]);
    int s;
    foreach (arr[i]) s += arr[i];
    return s;
  endfunction
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
