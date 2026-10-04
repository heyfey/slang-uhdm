// § tpGroupOneSpan234: a three-parameter chain with a typedef of the last
package p;
  class item; endclass
  class base #(type A = item, type B = A, type C = B);
    typedef C c_type;
    A a_buf[$];
    C c_one;
    function void pa(A x); endfunction
    function void pc(C y); endfunction
  endclass
endpackage
