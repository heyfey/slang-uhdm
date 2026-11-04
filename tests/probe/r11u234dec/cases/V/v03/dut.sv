// § decode V: v01 returning the parameterized class without a specialization (visitor)
package p;
  class comp; endclass
  virtual class visitor #(type NODE = int);
  endclass
  virtual class coreservice;
    pure virtual function visitor get_component_visitor();
  endclass
endpackage
