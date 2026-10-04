// § decode E: e20 with the specialization written with another enum typedef (W#(f_t)): the generic class keeps its default
package p;
  typedef enum bit { A=0, B=1 } e_t;
  typedef enum bit [1:0] { X=0, Y=1, Z=2 } f_t;
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
    f_t is_active;
    function void apply(string s);
      f_t v;
      if (W#(f_t)::from_name(s, v)) is_active = v;
    endfunction
  endclass
endpackage
