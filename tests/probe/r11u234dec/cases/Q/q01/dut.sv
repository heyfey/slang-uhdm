// § decode Q (N0232): uvm_report_message_element_container's shape, a class-scope queue typedef of a class handle returned by a virtual method
package p;
  class el; endclass
  class cont;
    el elements[$];
    typedef el queue_of_element[$];
    virtual function queue_of_element get_elements();
      return elements;
    endfunction
  endclass
endpackage
