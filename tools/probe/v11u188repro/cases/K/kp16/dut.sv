// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = int);
    T arr[3];
    function void f();
      foreach (arr[i]) begin
        T tmp;
        tmp = arr[i];
      end
      for (int j = 0; j < 3; j++) begin
        automatic T t2 = arr[j];
      end
    endfunction
  endclass
endpackage
module top; endmodule
