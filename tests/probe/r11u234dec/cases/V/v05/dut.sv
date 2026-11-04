// § decode V: v01 with a package function (no class) returning the specialization
package p;
  class comp; endclass
  virtual class visitor #(type NODE = int);
  endclass
  function visitor#(comp) get_component_visitor();
    return null;
  endfunction
endpackage
