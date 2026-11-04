// wc3 -- an INSTANTIATED interface's nets over an INTERFACE-homed and a
// $unit-homed scoped-target typedef.
package pk;
  typedef logic [1:0] cv_t;
  typedef reg   [1:0] cr_t;
endpackage
typedef pk::cv_t uq_t;
typedef pk::cr_t uqr_t;
interface ifs;
  typedef pk::cv_t iq_t;
  wire uq_t  s01;
  uq_t       s02;
  wire uqr_t s03;
  wire iq_t  s04;
  iq_t       s05;
endinterface
module wc3;
  ifs u_ifs ();
  logic q;
  assign q = u_ifs.s01[0];
endmodule
