// § dottedPropRootUnitImport403
package p;
class C;
  bit m_s[C];
  C m_end;
  extern function void add(C fp, int x);
endclass
function void C::add(C fp, int x);
    if (fp != null) begin
      foreach (fp.m_s[succ]) begin succ.m_s[fp] = 1; end
      if (x == 0) begin
        fp.m_s = m_end.m_s;
        foreach (m_end.m_s[succ]) begin succ.m_s[fp] = 1; end
      end
    end
endfunction
endpackage
import p::*;
module top; endmodule
