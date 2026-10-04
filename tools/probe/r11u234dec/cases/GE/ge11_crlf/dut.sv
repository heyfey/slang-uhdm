// § tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234: e01 with CRLF line endings
package p;
  typedef enum bit { A=0, B=1 } e_t;
  class W #(type T=e_t);
    protected static T map[string];
    static function bit from_name(string name, ref T value);
      if (map.exists(name)) begin
        value = map[name];
        return 1;
      end
      return 0;
    endfunction
    protected static function void m_init_map();
      T e = e.first();
      map[e.name()] = e;
    endfunction
  endclass
endpackage
