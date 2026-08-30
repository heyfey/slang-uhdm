// r10earl101 g5_neg101 -- THE NEGATIVE CONTROL.  Nothing here is the law's
// shape, and the two binaries must produce BYTE-IDENTICAL databases on it.
//
//  * a MODULE-LOCAL typedef under a packed dimension on a port (no package
//    listing object exists, so `pkgScalarTd` never holds it)
//  * a $unit-scope typedef (its listing object carries NO "::", the case
//    r10earl96 R2 showed bareScalarTdCopyOfFresh16 mangles -- the law's
//    `find("::")` guard is what keeps it out)
//  * the package's OWN two views of the same typedef
//  * a package AGGREGATE typedef (enum / struct) on a packed-vector port
//  * a package scalar typedef on a port with NO packed dimension
package p5n101;
  typedef logic [7:0] n_t;
  typedef enum logic [1:0] { N0, N1 } ne_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } ns_t;
  // the package's own uses of its own typedef
  n_t [3:0] pkg_arr;
  function automatic n_t [1:0] pf (input n_t [1:0] a);
    n_t [1:0] loc;
    loc = a;
    return loc;
  endfunction
endpackage

typedef logic [7:0] u_t;         // a $unit typedef -- NO package qualifier

module m5loc101
  import p5n101::*;
(
  input  u_t  [3:0] i_unit,      // $unit typedef under a packed dim
  output u_t  [3:0] o_unit,
  input  ne_t [3:0] i_enum,      // package AGGREGATE kinds
  output ne_t [3:0] o_enum,
  input  ns_t [3:0] i_str,
  output ns_t [3:0] o_str,
  input  n_t        i_scalar,    // package scalar, NO packed dim
  output n_t        o_scalar
);
  typedef logic [7:0] own_t;     // a MODULE-LOCAL typedef
  own_t [3:0] w_own;
  assign w_own   = {i_unit};
  assign o_unit  = w_own;
  assign o_enum  = i_enum;
  assign o_str   = i_str;
  assign o_scalar = i_scalar;
endmodule

module g5_neg101 (input logic clk);
  u_t        [3:0] a_i, a_o;
  p5n101::ne_t [3:0] b_i, b_o;
  p5n101::ns_t [3:0] c_i, c_o;
  p5n101::n_t        d_i, d_o;
  m5loc101 u_n (.i_unit(a_i), .o_unit(a_o), .i_enum(b_i), .o_enum(b_o),
                .i_str(c_i), .o_str(c_o), .i_scalar(d_i), .o_scalar(d_o));
endmodule
