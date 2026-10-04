// § retNameLocalClassTsAtType234: an out-of-body method returning a specialization, its name assigned in the body
package p;
  class vis #(type N = int); endclass
  class cs;
    extern function vis#(int) get_v();
  endclass
  function vis#(int) cs::get_v();
    get_v = null;
  endfunction
endpackage
