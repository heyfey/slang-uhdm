// § tfLocalClassArrElemClassTs452
package p;
  class C;
    int x;
  endclass
  class R;
    function void body();
      C a[2][3];
      C b[0:3];
    endfunction
  endclass
endpackage
module top;
endmodule
