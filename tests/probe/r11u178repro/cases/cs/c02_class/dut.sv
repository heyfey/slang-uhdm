// § hierPathSelIdxAtPath178
package pack;
class c;
  int arr[4];
  function int g(int x); return x; endfunction
  function int f(int k);
    int r;
    r = arr[g(k)];
    r += arr[this.g(k)];
    return r;
  endfunction
endclass
endpackage
