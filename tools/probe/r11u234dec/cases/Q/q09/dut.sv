// § decode Q: q01 with a dynamic array of class handles
package p;
  class el; endclass
  class cont;
    el elements[];
    typedef el d_t[];
    virtual function d_t get_elements();
      return elements;
    endfunction
  endclass
endpackage
