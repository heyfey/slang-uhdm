// § pkgHoistArrNetElemDimSpan293
// Two declarators of one declaration.
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } st_t;
  typedef union packed { logic [7:0] a; logic [7:0] b; } un_t;
  typedef logic [7:0] w_t;
  typedef enum logic [1:0] { EA, EB } e_t;
  typedef struct packed { logic [3:0] a; st_t b; } sx_t;
  st_t v [0:1], x [0:3];
endpackage
module top(output logic o);
  import pk::*;
  assign o = ^{v[0].a, x[3].b};
endmodule
