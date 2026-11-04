// § decode Q: q01 with a non-virtual method
package p;
  class el; endclass
  class cont;
    el elements[$];
    typedef el queue_of_element[$];
    function queue_of_element get_elements();
      return elements;
    endfunction
  endclass
endpackage
