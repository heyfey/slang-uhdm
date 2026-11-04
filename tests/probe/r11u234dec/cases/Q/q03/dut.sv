// § decode Q: q01 with a fixed unpacked array typedef
package p;
  class el; endclass
  class cont;
    el elements[4];
    typedef el arr_t[4];
    virtual function arr_t get_elements();
      return elements;
    endfunction
  endclass
endpackage
