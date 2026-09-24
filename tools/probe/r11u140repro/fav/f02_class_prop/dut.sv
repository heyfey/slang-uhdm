// § foreachArrayPlaceholderFile140
package pack;
class c;
  int arr[];
  function int f();
    int s = 0;
    foreach (arr[i]) s += arr[i];
    return s;
  endfunction
endclass
endpackage
