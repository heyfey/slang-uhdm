// § oobClassTdFirstClassKey231 — a task, a second formal and a return type of the class typedef
package p;
  class cmpA;
    typedef cmpA this_type;
  endclass
  class lib;
    typedef lib this_type;
    extern task t(int n, this_type a, this_type b);
    extern function this_type get();
  endclass
  task lib::t(int n, this_type a, this_type b);
  endtask
  function lib::this_type lib::get();
    return null;
  endfunction
endpackage
module top;
endmodule
