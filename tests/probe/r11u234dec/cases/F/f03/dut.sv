// § decode F: uvm_mem::get_default_map's shape, the function's own name passed to an associative array's first()
package p;
  class rmap; endclass
  class mem;
    protected bit m_maps[rmap];
    extern function rmap get_default_map();
  endclass
  function rmap mem::get_default_map();
    if (m_maps.num() == 1) begin
      void'(m_maps.first(get_default_map));
    end
  endfunction
endpackage
