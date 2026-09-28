// § typeParamUseSharesOwnTs183 § typeParamDefersToTpUse186: a class type parameter defaulting to a class, used in a task formal, a nested begin local and a property, and a second class handle named like the parameter in another class (the gate's lookup)
package p;
  class base; endclass
  class holder #(type T = base);
    T keep;
    task put(input T x);
      begin : nb
        T tmp;
        tmp = x;
        keep = tmp;
      end
    endtask
  endclass
  class other;
    base T;
    function void f();
      T = null;
    endfunction
  endclass
endpackage
module top; endmodule
