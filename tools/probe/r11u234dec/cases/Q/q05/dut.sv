// § decode Q: q01 with the queue typedef at package scope
package p;
  class el; endclass
  typedef el queue_of_element[$];
  class cont;
    el elements[$];
    virtual function queue_of_element get_elements();
      return elements;
    endfunction
  endclass
endpackage
