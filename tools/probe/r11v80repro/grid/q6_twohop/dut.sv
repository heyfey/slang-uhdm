// v11u80 q6 -- THE AUTOMATIC/ROAD PREDICATE'S BOUNDARY.  pkgDataDeclRoad80
// returns TRUE for any DataDeclaration whose written type is not a plain
// NamedType, or which carries `const`/`var`; it stamps vpiAutomatic unless
// `static` is written, and stamps it when `automatic` is.  r11u80 measured the
// keyword-spelled and the typedef-spelled roads but not the lifetime keywords
// on an UNPACKED array, nor `const` on an aggregate element, nor a
// var-qualified enum/union, nor the signed faces.
package pq6;
  typedef struct packed { int x; logic [7:0] y; } si_t;
  typedef union packed { logic [15:0] a; logic [15:0] b; } un_t;
  typedef enum logic [1:0] { PA, PB } en_t;
  typedef logic [7:0] w_t;
  typedef reg   [7:0] r_t;
  typedef bit   [7:0] b_t;

  logic [7:0]        a_plain  [0:1];   // data road  -> auto 1
  w_t                a_tdw    [0:1];   // net road   -> auto 0
  r_t                a_tdr    [0:1];   // net road   -> array_net
  b_t                a_tdb    [0:1];   // net road, 2-state typedef
  static logic [7:0] a_stat   [0:1];   // `static` on the data road
  var   logic [7:0]  a_var    [0:1];   // `var` on the keyword road
  var   w_t          a_vtdw   [0:1];   // `var` on the typedef road
  var   r_t          a_vtdr   [0:1];   // `var` on the reg typedef road
  var   si_t         a_vsi    [0:1];   // `var` + int-member struct
  var   un_t         a_vun    [0:1];   // `var` + union
  var   en_t         a_ven    [0:1];   // `var` + enum
  const logic [7:0]  a_klog   [0:1] = '{default: 8'd0};  // const integral
  const si_t         a_ksi    [0:1] = '{default: '0};    // const aggregate
  logic signed [7:0] a_slog   [0:1];   // written `signed`
  int signed         a_sint   [0:1];   // signed atom
  int unsigned       a_uint   [0:1];   // unsigned atom
  wire signed [7:0]  a_nslog  [0:1];   // signed NET
endpackage

module dut (output logic [31:0] o);
  import pq6::*;
  assign o = {24'd0, a_plain[0]} ^ {24'd0, a_tdw[0]} ^ {24'd0, a_tdr[0]}
           ^ {24'd0, a_tdb[0]} ^ {24'd0, a_stat[0]} ^ {24'd0, a_var[0]}
           ^ {24'd0, a_vtdw[0]} ^ {24'd0, a_vtdr[0]} ^ {24'd0, a_vsi[0].y}
           ^ {16'd0, a_vun[0].a} ^ {30'd0, a_ven[0]}
           ^ {24'd0, a_klog[0]} ^ {24'd0, a_ksi[0].y}
           ^ {24'd0, a_slog[0]} ^ a_sint[0] ^ a_uint[0] ^ {24'd0, a_nslog[0]};
endmodule
