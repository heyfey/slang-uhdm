// § structCopyNestedAnnotDeep232
package p;
  typedef struct { int a = 1; bit f = 1'b1; } in_t;
  typedef struct { in_t i; int d = 4; } out_t;
endpackage
// unpacked structs with member defaults: variables, a nested member
module top import p::*; (output int o);
  out_t v;
  in_t w;
  assign o = v.i.a + w.a + v.d;
endmodule
