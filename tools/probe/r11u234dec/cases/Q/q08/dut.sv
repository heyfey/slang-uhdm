// § decode Q: q01 with an associative array of class handles
package p;
  class el; endclass
  class cont;
    el elements[string];
    typedef el assoc_t[string];
    virtual function assoc_t get_elements();
      return elements;
    endfunction
  endclass
endpackage
