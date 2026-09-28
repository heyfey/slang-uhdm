  class cb #(type T = int, type CB = int);
    typedef cb #(T, CB) this_type;
    static this_type m_inst;
    static function this_type get();
      if (m_inst == null) m_inst = new;
      return m_inst;
    endfunction
  endclass
