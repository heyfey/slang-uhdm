// § decode E: e01 plus a specialization written with the default's own typedef (W#(e_t)::from_name, uvm_component's shape)
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
  class comp;
    e_t is_active;
    function void apply(string s);
      e_t v;
      if (W#(e_t)::from_name(s, v)) is_active = v;
    endfunction
  endclass
endpackage
