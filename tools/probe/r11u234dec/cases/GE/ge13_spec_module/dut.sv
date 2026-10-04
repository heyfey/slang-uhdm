// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: specializations with the default's typedef and another typedef, used from a module
package p;
  typedef enum bit { A=0, B=1 } e_t;
  typedef enum bit [1:0] { X=0, Y=1, Z=2 } f_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
module top;
  import p::*;
  W #(e_t) w1;
  W #(f_t) w2;
  W w3;
endmodule
