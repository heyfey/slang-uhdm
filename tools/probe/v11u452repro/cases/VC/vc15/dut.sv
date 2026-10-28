// § tfLocalClassArrElemClassTs452
class C;
  int x;
endclass
module top;
  function automatic void f();
    C a[2][3];
    C b[0:1];
  endfunction
endmodule
