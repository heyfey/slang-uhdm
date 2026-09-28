// § classTdAliasLastWriter214 — two typedefs specializing one generic package class (the uvm_barrier_pool / uvm_event_pool alias shape), importer case i01_none
package p;
  class c #(type T = int);
    T v;
  endclass
  typedef c #(int) bar_pool_t;
  typedef c #(byte) ev_pool_t;
  class user;
    ev_pool_t q;
    bar_pool_t r;
  endclass
endpackage

