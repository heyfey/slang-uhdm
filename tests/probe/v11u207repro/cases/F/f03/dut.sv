// § foreachThisArrAtThisToken207: this.<array> with whitespace and a line break around the dot, an escaped name, and one-letter and very long names
package p;
class C;
  int x[3];
  int \esc$arr [2];
  int a_very_long_array_name_for_span[2];
  function void f();
    foreach (this . x[i]) x[i] = 0;
    foreach (this.
             x[i]) x[i] = 1;
    foreach (this.\esc$arr [i]) \esc$arr [i] = 2;
    foreach (this.a_very_long_array_name_for_span[i]) a_very_long_array_name_for_span[i] = 3;
  endfunction
endclass
endpackage
module top; endmodule
