// § tfLocalClassArrElemClassTs452
package p;
  class B;
    int x;
  endclass
  function automatic void f();
    B arr[2];
    begin
      B inner[4];
      inner[0] = arr[1];
    end
  endfunction
endpackage
module top;
endmodule
