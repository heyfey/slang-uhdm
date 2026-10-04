// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: properties written T with every container: fixed, queue, dynamic, associative, packed
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    T fx[4];
    T qu[$];
    T dy[];
    T as[int];
    T [1:0] pk;
    function void f(T a); endfunction
  endclass
endpackage
