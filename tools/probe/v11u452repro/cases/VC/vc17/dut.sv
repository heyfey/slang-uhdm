// § tfLocalClassArrElemClassTs452
class C;
  int x;
endclass
function automatic void f();
  C arr[2];
endfunction
module top;
  initial f();
endmodule
