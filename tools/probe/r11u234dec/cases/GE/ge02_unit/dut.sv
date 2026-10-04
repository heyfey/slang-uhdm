// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: a $unit typedef and a $unit class (not a package: both laws decline)
typedef enum bit { A=0, B=1 } e_t;
class W #(type T=e_t);
  static T m;
  function void f(T a); endfunction
endclass
module top; endmodule
