// § decode Q: q01 with an enum element (typedef e_t eq_t[$]): golden keeps the twin
package p;
  typedef enum bit { A, B } e_t;
  class cont;
    e_t elements[$];
    typedef e_t eq_t[$];
    virtual function eq_t get_elements();
      return elements;
    endfunction
  endclass
endpackage
