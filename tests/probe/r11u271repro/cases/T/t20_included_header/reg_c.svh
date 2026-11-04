// § tpUseSharesOwnTs271
  class reg_c #(type T = comp, string Tname = "<unknown>");
    T m;
    function void setm(T v);
      m = v;
    endfunction
    function T g();
      T o;
      o = m;
      return o;
    endfunction
  endclass
