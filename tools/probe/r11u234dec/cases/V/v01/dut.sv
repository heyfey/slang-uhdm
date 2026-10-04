// § decode V (N0256): uvm_coreservice_t's shape, a pure virtual function returning a parameterized class specialization
package p;
  class comp; endclass
  virtual class visitor #(type NODE = int);
  endclass
  virtual class coreservice;
    pure virtual function visitor#(comp) get_component_visitor();
  endclass
endpackage
