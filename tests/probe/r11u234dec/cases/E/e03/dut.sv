// § decode E: e01 with only the method local written T (no property, no formal)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    static function void m_init_map();
      T e = e.first();
      e = e.next();
    endfunction
  endclass
endpackage
