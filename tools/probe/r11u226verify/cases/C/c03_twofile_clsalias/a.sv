// § classTdAliasLastWriter214 — the home package in one file, a $unit import and two $unit classes over two files
package p;
  class box #(type T = int); T v; endclass
  typedef box #(longint) lbox_t;
  typedef box #(longint) lbox2_t;
endpackage
import p::*;
class mm_c; lbox2_t m; endclass
