// v4: CROSS-PACKAGE + import axis.  A class in package B whose method returns a
// typedef homed in package A, written bare (via wildcard import), explicitly
// imported, or fully qualified.  Plus the same typedef used by A's own class.
package vpa;
  parameter int PW = 4096;
  typedef logic signed [PW-1:0] bs_t;
  class CA; extern function bs_t a_ret(); endclass
  function bs_t CA::a_ret(); a_ret = 'b0; endfunction
endpackage

package vpb;
  import vpa::*;                 // wildcard
  class CB;
    extern function bs_t      b_ret_bare();   // bare via wildcard import
    extern function vpa::bs_t b_ret_qual();
  endclass
  function bs_t      CB::b_ret_bare(); b_ret_bare = 'b0; endfunction
  function vpa::bs_t CB::b_ret_qual(); b_ret_qual = 'b0; endfunction
endpackage

package vpc;
  import vpa::bs_t;              // explicit
  class CC;
    extern function bs_t c_ret_bare();
  endclass
  function bs_t CC::c_ret_bare(); c_ret_bare = 'b0; endfunction
endpackage

package vpd;                     // re-typedef of another package's typedef
  import vpa::*;
  typedef vpa::bs_t d_t;
  class CD; extern function d_t d_ret(); endclass
  function d_t CD::d_ret(); d_ret = 'b0; endfunction
endpackage

module vt4;
  import vpa::*; import vpb::*; import vpc::*; import vpd::*;
  vpa::bs_t w;
  vpa::CA a; vpb::CB b; vpc::CC c; vpd::CD d;
  initial begin a=new(); b=new(); c=new(); d=new();
    w = a.a_ret() + b.b_ret_bare() + c.c_ret_bare() + d.d_ret(); end
endmodule
