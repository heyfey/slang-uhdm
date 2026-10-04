// § decode E: e01 without the formal written T (no writer of the shared enum object)
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    protected static T map[string];
    static function bit from_name(string name);
      return map.exists(name);
    endfunction
    protected static function void m_init_map();
      T e = e.first();
      map[e.name()] = e;
    endfunction
  endclass
endpackage
