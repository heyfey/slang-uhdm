// vsd11 vc — THE REACH QUESTION, isolated from the CLAIM question.
// Surelog repairs the placeholder through `specs[<declaring class NAME>::<td
// name>]`, looked up by the WRITTEN text.  So a written owner that is NOT the
// class the typedef was DECLARED in can never be repaired, whatever the claim
// says.  Every typedef below is the SOLE namer of its target, so the CLAIM is
// satisfied for all of them and only REACH can separate them.
package pvc;

  class zc1;
    int q;
  endclass
  class zc2;
    int q;
  endclass
  class zc3;
    int q;
  endclass

  class abasec;
    typedef zc1 inh_t;         // sole namer of zc1
    class innerc;
      typedef zc2 deep_t;      // sole namer of zc2
    endclass
  endclass

  class adervc extends abasec;
    typedef zc3 own_t;         // sole namer of zc3
    function void fc();
      abasec::inh_t         v_decl;   // written on the DECLARING class
      adervc::inh_t         v_inh;    // written on the DERIVED class
      adervc::own_t         v_own;    // written on the DECLARING class
      abasec::innerc::deep_t v_deep;  // MULTI-SEGMENT
      innerc::deep_t        v_seg1;   // ONE segment, the declaring class
      v_decl = null;
      v_inh = null;
      v_own = null;
      v_deep = null;
      v_seg1 = null;
    endfunction
  endclass

endpackage

module topvc;
  initial begin
    pvc::adervc d = new();
    d.fc();
  end
endmodule
