// § pkgArrTdElemClone209 — r11u217 h03: UNPACKED package array typedefs (a fixed unpacked array, a dynamic array and a queue of a struct element) beside a packed one, all read by a module
package q;
  typedef struct packed { logic y; logic z; } s_t;
  typedef s_t [1:0] pv_t;
  typedef s_t uv_t [2];
  typedef s_t dv_t [];
  typedef s_t qv_t [$];
endpackage
module top (output logic o, output logic p);
  q::pv_t a;
  q::uv_t b;
  q::dv_t d;
  q::qv_t e;
  assign a = '0;
  assign b[0] = '0;
  assign b[1] = '1;
  assign o = a[1].z;
  assign p = b[1].y;
endmodule
