// § tfArgTypeParamDefaultWriter231 — two classes write the enum, the class-map name order picks the last
package p;
  typedef enum {A0, A1, A2} e_t;
  class zz #(type T=e_t);
    function void put(T v);
    endfunction
  endclass
  class aa #(type U=e_t);
    function void get(int n, ref U u);
    endfunction
  endclass
endpackage
module top;
endmodule
