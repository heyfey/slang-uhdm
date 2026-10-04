// § decode V: v01 as an extern prototype with an out-of-body body
package p;
  class comp; endclass
  virtual class visitor #(type NODE = int);
  endclass
  class coreservice;
    extern virtual function visitor#(comp) get_component_visitor();
  endclass
  function visitor#(comp) coreservice::get_component_visitor();
    return null;
  endfunction
endpackage
