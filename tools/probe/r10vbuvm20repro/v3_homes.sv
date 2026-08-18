// v3: HOME axis -- class in package / class in module / class in interface /
// class in program / class in $unit / class in a generate block, all returning
// the SAME package typedef, plus nested + parameterized classes.
typedef logic signed [15:0] unit_bs_t;

package vp3;
  parameter int PW = 4096;
  typedef logic signed [PW-1:0] bs_t;

  class Outer;
    class Inner;                             // nested class in package
      function bs_t nest_ret(); nest_ret = 'b0; endfunction
    endclass
    extern function bs_t outer_ret();
  endclass
  function bs_t Outer::outer_ret(); outer_ret = 'b0; endfunction

  class Param #(int W = 8);                  // parameterized class in package
    extern function bs_t p_ret();
  endclass
  function bs_t Param::p_ret(); p_ret = 'b0; endfunction

  class Base;  extern virtual function bs_t v_ret(); endclass
  class Deriv extends Base; extern virtual function bs_t v_ret(); endclass
  function bs_t Base::v_ret();  v_ret = 'b0; endfunction
  function bs_t Deriv::v_ret(); v_ret = 'b1; endfunction
endpackage

class UnitC;                                 // class in $unit returning $unit typedef
  extern function unit_bs_t u_ret();
endclass
function unit_bs_t UnitC::u_ret(); u_ret = 'b0; endfunction

class UnitC2;                                // class in $unit returning a PACKAGE typedef
  extern function vp3::bs_t up_ret();
endclass
function vp3::bs_t UnitC2::up_ret(); up_ret = 'b0; endfunction

module vt3;
  import vp3::*;
  class ModC;                                // class in module
    extern function vp3::bs_t m_ret();
    extern function bs_t m_ret_bare();
  endclass
  function vp3::bs_t ModC::m_ret(); m_ret = 'b0; endfunction
  function bs_t ModC::m_ret_bare(); m_ret_bare = 'b0; endfunction

  if (1) begin : g
    class GenC; extern function vp3::bs_t g_ret(); endclass
    function vp3::bs_t GenC::g_ret(); g_ret = 'b0; endfunction
  end

  vp3::bs_t w;
  vp3::Outer o; vp3::Param #(4) p; vp3::Deriv d; UnitC uc; UnitC2 uc2; ModC mc;
  initial begin
    o = new(); p = new(); d = new(); uc = new(); uc2 = new(); mc = new();
    w = o.outer_ret() + p.p_ret() + d.v_ret() + uc2.up_ret() + mc.m_ret();
  end
endmodule

interface vi3;
  import vp3::*;
  class IfC; extern function vp3::bs_t i_ret(); extern function bs_t i_ret_bare(); endclass
  function vp3::bs_t IfC::i_ret(); i_ret = 'b0; endfunction
  function bs_t IfC::i_ret_bare(); i_ret_bare = 'b0; endfunction
endinterface

program vpg3;
  import vp3::*;
  class PgC; extern function vp3::bs_t p_ret(); extern function bs_t p_ret_bare(); endclass
  function vp3::bs_t PgC::p_ret(); p_ret = 'b0; endfunction
  function bs_t PgC::p_ret_bare(); p_ret_bare = 'b0; endfunction
endprogram
