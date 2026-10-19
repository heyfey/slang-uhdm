// § dottedPropRootUnitImport403
package p;
class C;
  bit m_s[C];
  C m_end;
  extern function void add(C fp, int x);
endclass
function void C::add(C fp, int x);
    foreach (fp.m_s[succ]) succ.m_s[fp] = 1;
    foreach (m_end.m_s[succ]) succ.m_s[fp] = 1;
endfunction
endpackage
import p::*;
module top; endmodule
