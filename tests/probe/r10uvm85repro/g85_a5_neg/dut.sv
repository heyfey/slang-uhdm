// r10uvm85 arm a5 — the NEGATIVE CONTROLS this law must not disturb: a
// receiver that is NOT an implicit class handle (flat and deep), and the
// EXPRESSION-position spellings that are § thisDeepStepMockupConst84's.
module g85a5;
  class inner5;
    int      arr[$];
    function void um5(int a); endfunction
  endclass
  class c5;
    inner5   h;
    inner5   oth;
    int      q[$];
    int      n;
    int      loc[$];
    function void f(int k);
      int lq[$];
      lq.delete(0);              // L17 FLAT non-this builtin, stmt
      lq.push_back(k);           // L18
      loc.delete(0);             // L19 FLAT class-property receiver, stmt
      h.arr.delete(0);           // L20 DEEP non-this builtin, stmt
      h.um5(k);                  // L21 DEEP non-this user, stmt
      oth.arr.push_back(k);      // L22
      if (this.q.size() > 0)     // L23 EXPRESSION position: the MOCKUP
        this.n = 1;
      this.n = this.q.size();    // L24 EXPRESSION position: the MOCKUP
      void'(this.q.size());      // L25 cast-wrapped: statement-SHAPED?
      this.q.delete(k);          // L26 positive control
    endfunction
  endclass
endmodule
