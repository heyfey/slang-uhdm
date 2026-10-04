// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: locals written T in a nested begin block and in a task
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    function void f(T a);
      begin
        T b = a;
        b = b.next();
      end
    endfunction
    task t();
      T c = c.first();
      c = c.last();
    endtask
  endclass
endpackage
