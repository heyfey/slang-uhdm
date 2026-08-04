package pk;
  typedef struct packed { logic p; logic n; } st;
endpackage

typedef struct packed { logic p; logic n; } file_t;

module child
   import pk::*;
(
   input  st [2:0] a,          // imported bare name, packed dim
   input  pk::st [1:0] c,      // pkg-qualified, packed dim
   input  file_t [1:0] e,      // $unit typedef, packed dim
   input  st g,                // imported bare name, scalar
   input  pk::st h,            // pkg-qualified, scalar
   input  file_t i,            // $unit typedef, scalar
   output st [2:0] oa,         // imported bare, packed dim, OUTPUT
   output pk::st [1:0] oc,     // pkg-qualified, packed dim, OUTPUT
   output st og,               // imported bare, scalar, OUTPUT
   output pk::st oh,           // pkg-qualified, scalar, OUTPUT
   output int x
);
   assign x = int'(a);
endmodule

module top(output int o);
   child u(.a('0), .c('0), .e('0), .g('0), .h('0), .i('0),
           .oa(), .oc(), .og(), .oh(), .x(o));
endmodule
