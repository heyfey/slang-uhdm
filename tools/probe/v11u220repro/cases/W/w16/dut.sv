// § newArrayBitSelIdxStripped220
package p1;
  class c;
    int d[];
    int arr[4];
    function void f(int k);
      d = new[arr[k]];
    endfunction
  endclass
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
