// § classTdAliasLastWriter214 — a package class-specialization typedef (uvm_event_pool's shape), no importer
package p;
  class c #(type T = int);
    T v;
  endclass
  typedef c #(int) pool_t;
  class user;
    pool_t q;
  endclass
endpackage
