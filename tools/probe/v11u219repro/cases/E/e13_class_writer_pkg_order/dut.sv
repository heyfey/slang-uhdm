// § classTdAliasLastWriter214 — the aliased class specialization typedef imported by two packages declared against name order and by no module
package p;
  class box #(type T = int); T v; endclass
  typedef box #(byte) bbox_t;
  typedef box #(byte) bbox2_t;
endpackage
package zq;
  import p::*;
  class zc; bbox2_t h; endclass
endpackage
package aq;
  import p::*;
  class ac; bbox2_t g; endclass
endpackage
module top;
  import zq::*;
  import aq::*;
endmodule
