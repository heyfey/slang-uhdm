// a7 — TWO foreign generics, INTERLEAVED.  Two independent groups, each with
// its own base; mirrors uvm_component_registry / uvm_object_registry.
// Group P base should be "pk7use::Ba7" (B<c<y); group Q base "pk7use::Cq7".
package pk7box;
  class BoxP7 #(type Q = int, string Nm = "?"); int p7; endclass
  class BoxQ7 #(type Q = int, string Nm = "?"); int q7; endclass
endpackage
package pk7use;
  import pk7box::*;
  class yy7;  typedef BoxP7 #(yy7,"yy7") pid7;
  endclass
  class Zq7;  typedef BoxQ7 #(Zq7,"Zq7") qid7;
  endclass
  class cc7;  typedef BoxP7 #(cc7,"cc7") pid7;
  endclass
  class Cq7;  typedef BoxQ7 #(Cq7,"Cq7") qid7;
  endclass
  class Ba7;  typedef BoxP7 #(Ba7,"Ba7") pid7;
  endclass
endpackage
