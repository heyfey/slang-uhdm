// r10v123 arm D — SCOPES that must NOT be recorded (parent scope not a package)
// living beside ones that must be: a $unit typedef, a class-scope typedef, a
// module-local typedef, an interface-local typedef, plus the package control.
typedef bit [9:0] iron123_unit_t;          // $unit
typedef logic [4:0] iron123_lunit_t;       // $unit

package juniper123_pkg;
  typedef bit   [7:0] jun_bit_t;           // the CONTROL: must move
  typedef logic [5:0] jun_log_t;
  class JunHolder;
    typedef bit [3:0] jun_cls_t;           // class scope: must NOT move
    function int jh(int qq);
      jun_cls_t cc; jun_bit_t bb;
      cc = jun_cls_t'(qq);
      bb = jun_bit_t'(qq);
      return int'(cc) + int'(bb);
    endfunction
  endclass
  function automatic int jun_home(int qq);
    jun_bit_t bb2; jun_log_t ll2;
    bb2 = jun_bit_t'(qq);
    ll2 = jun_log_t'(qq);
    return int'(bb2) + int'(ll2);
  endfunction
endpackage

module iron_top;
  import juniper123_pkg::*;
  typedef bit [6:0] iron_mod_t;            // module scope: must NOT move
  iron_mod_t mm;
  iron123_unit_t uu;
  jun_bit_t jj;
  assign mm = iron_mod_t'(3);
  assign uu = iron123_unit_t'(4);
  assign jj = jun_bit_t'(5);
  function automatic int iron_sub(int qq);
    iron_mod_t     m1;
    iron123_unit_t u1;
    iron123_lunit_t l1;
    jun_bit_t      j1;
    m1 = iron_mod_t'(qq);
    u1 = iron123_unit_t'(qq);
    l1 = iron123_lunit_t'(qq);
    j1 = jun_bit_t'(qq);
    return int'(m1) + int'(u1) + int'(l1) + int'(j1);
  endfunction
  initial begin
    int rr;
    rr = iron_sub(1) + jun_home(2);
  end
endmodule

interface kapok123_if;
  import juniper123_pkg::*;
  typedef logic [2:0] kapok_if_t;          // interface scope: must NOT move
  function automatic int kapok_sub(int qq);
    kapok_if_t k1; jun_log_t j2;
    k1 = kapok_if_t'(qq);
    j2 = jun_log_t'(qq);
    return int'(k1) + int'(j2);
  endfunction
endinterface
