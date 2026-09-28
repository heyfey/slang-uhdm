// § typeParamUseSharesOwnTs183 § typeParamDefersToTpUse186 § typeParamGateNoLookup186: a class type parameter with a class default used by locals of a function and a task (two each), a property and a static method's local, the class specialized twice
package p;
  class base; endclass
  class other; endclass
  class holder #(type H = base);
    H keep;
    function void run();
      H a1;
      H a2;
      a1 = keep;
    endfunction
    task go();
      H t1;
    endtask
    static function void sf();
      H s1;
    endfunction
  endclass
  class user;
    holder #(other) ho;
    holder hb;
  endclass
endpackage
module top; endmodule
