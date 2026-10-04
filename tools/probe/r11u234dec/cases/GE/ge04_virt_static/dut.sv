// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: a virtual method, a static method and a task, each with a formal written T
package p;
  typedef enum bit [1:0] { A=0, B=1, C=2 } e_t;
  class W #(type T=e_t);
    T m;
    virtual function void v(T a); endfunction
    static function void s(input T b); endfunction
    task t(output T c); c = A; endtask
  endclass
endpackage
