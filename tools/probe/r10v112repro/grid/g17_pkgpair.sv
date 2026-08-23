// g17 — TWO PACKAGE-SCOPE typedefs of one generic with DIFFERENT arguments.
// The package clone loop (src/ParamEmit.cpp, § pkgImportClassTdClone50 and its
// sibling) copies SPAN and ALIAS but never the specialization at all.
package p17box;
  class B17 #(type Q = int, string Nm = "?"); int x17; endclass
endpackage
package p17use;
  import p17box::*;
  class aa17; int a17; endclass
  class zz17; int z17; endclass
  typedef B17 #(zz17,"zz17") zid17;
  typedef B17 #(aa17,"aa17") aid17;
endpackage
