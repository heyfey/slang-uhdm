// § foreachArrayPlaceholderFile140
package pack;
class c;
  int m[2][3];
  function int f();
    int s = 0;
    foreach (m[i, j]) s += m[i][j];
    return s;
  endfunction
endclass
endpackage
