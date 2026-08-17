// vsd11 va — WHY does a NESTED class's typedef claim ahead of its OUTER class's?
// v3 measured that it does.  Two models fit:
//   (M1) the nested class's registered key is its SHORT name (`binner3`), which
//        sorts before every `pkg::…` key;
//   (M2) nested classes are simply reached EARLIER, whatever they are called.
// This cell renames the nested class so its SHORT name sorts LAST of everything
// in the package.  Under M1 the OUTER typedef claims; under M2 the NESTED one
// still does.
package pva;

  class zela;
    int q;
  endclass

  class aouta;                 // short "aouta", pkg key "pva::aouta"
    typedef zela a_out;
    class zzinna;              // short "zzinna" — sorts AFTER "pva::aouta"
                               // under M1, but is still NESTED
      typedef zela z_in;
      function void fa();
        aouta::a_out  v_out;
        zzinna::z_in  v_in;
        v_out = null;
        v_in = null;
      endfunction
    endclass
  endclass

endpackage

module topva;
  initial begin
    pva::aouta::zzinna b = new();
    b.fa();
  end
endmodule
