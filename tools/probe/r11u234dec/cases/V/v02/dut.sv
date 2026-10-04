// § decode V: v01 with a non-pure virtual function (a body)
package p;
  class comp; endclass
  virtual class visitor #(type NODE = int);
  endclass
  virtual class coreservice;
    virtual function visitor#(comp) get_component_visitor();
      return null;
    endfunction
  endclass
endpackage
