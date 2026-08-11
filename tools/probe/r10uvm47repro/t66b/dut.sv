// r10uvm47 arm t66b — the UNMEASURED HALVES of
// § pkgParamInClassMethodStaysRef47, each of which t66a leaves open because the
// uvm site has the class, the method and the parameter all in ONE package.
//
//   C1  the CLASS lives in a MODULE, the parameter in a package
//   C2  the CLASS lives in the COMPILATION UNIT ($unit), parameter in a package
//   C3  the reference is written QUALIFIED (`u1::P`) inside a class method
//   C4  a class method reading a MODULE parameter (the class is in the module)
//   C5  a class method reading its OWN CLASS's localparam (the control that
//       must not move)
//   C6  a class method in a package reading ANOTHER package's parameter,
//       unqualified after a wildcard import
//
// If any of these disagrees with the package-class cell, the gate needs that
// predicate; if they agree, the law is "the reader is a class method body" and
// nothing narrower.  A law that only ever saw one spelling has an unmeasured
// half, and this arm is that half made measurable.
package u1;
  parameter U1_P = 4096;
endpackage

package u2;
  import u1::*;
  parameter U2_P = 512;
  class c_pkg;
    function int m_other(int s);
      int a;
      a = U1_P - s;            // C6: another package's param, unqualified
      return a;
    endfunction
    function int m_own(int s);
      int b;
      b = U2_P - s;            // the t66a baseline, repeated here
      return b;
    endfunction
  endclass
endpackage

// C2: a compilation-unit class.
import u1::*;
class c_unit;
  function int m(int s);
    int a;
    a = U1_P - s;
    return a;
  endfunction
endclass

module t66b;
  import u1::*;
  parameter M_P = 77;

  // C1 / C3 / C4 / C5: a class declared inside the module.
  class c_mod;
    localparam CL_P = 33;
    function int m_pkg(int s);
      int a;
      a = U1_P - s;            // C1: package param, unqualified
      return a;
    endfunction
    function int m_qual(int s);
      int b;
      b = u1::U1_P - s;        // C3: package param, QUALIFIED
      return b;
    endfunction
    function int m_mod(int s);
      int c;
      c = M_P - s;             // C4: MODULE param
      return c;
    endfunction
    function int m_cls(int s);
      int d;
      d = CL_P - s;            // C5: the class's own localparam
      return d;
    endfunction
  endclass

  initial begin
    c_mod  a = new();
    c_unit b = new();
    u2::c_pkg c = new();
    $display("%0d %0d %0d %0d %0d %0d %0d", a.m_pkg(1), a.m_qual(1),
             a.m_mod(1), a.m_cls(1), b.m(1), c.m_other(1), c.m_own(1));
  end
endmodule
