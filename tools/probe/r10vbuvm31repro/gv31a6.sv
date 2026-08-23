// v31a6 — $unit (compilation-unit) scope, plus queue/dyn concat shapes.
int  ud_pat[]        = '{1, 2, 3};
int  uaa[string]     = '{default: 0};
int  uq_pat[$]       = '{1, 2};
int  uq_cat[$]       = {1, 2};
int  ud_cat[]        = {1, 2};
int  ud_empty[]      = {};
int  uq_empty[$]     = {};

class v31uc;
  protected int ucaa[string] = '{default: 0};
            int ucd[]        = '{1, 2};
            int ucq[$]       = '{3};
            int ucc[]        = {4, 5};
endclass

module v31m6;
  v31uc h = new();
  initial $display(ud_pat.size(), uaa.size(), uq_pat.size(), h.ucd.size(),
                   ud_empty.size(), uq_empty.size(), uq_cat.size(), ud_cat.size(),
                   h.ucc.size(), h.ucq.size());
endmodule
