// r10buvm21repro/g21.sv — THE FORMAL-AS-INDEX BIND GRID.
// MEASUREMENT ONLY.  One Surelog run over this file answers, per cell,
// whether golden binds a subroutine FORMAL referenced as the INDEX of a
// select (and as a bare operand) to its `io_decl` via `ref_obj::Actual_group`.
//
// Axes: METHOD HOME (package free function / class IN-BODY method / class
// OUT-OF-BODY method / static method / module function) x CARRIER (`++` as the
// sole body statement / `++` inside begin-end / `++` under if / `--` / `+=` /
// plain assignment / return / call argument / condition) x ARRAY KIND
// (assoc-by-enum / assoc-by-int / assoc-by-string / queue / dynamic / fixed)
// x FORMAL DIRECTION (input / output / inout / ref).
package gp21;

  typedef enum { SEV_A, SEV_B, SEV_C } sev_e;

  class c21;
    int aa_enum[sev_e];      // assoc by enum
    int aa_int[int];         // assoc by int
    int aa_str[string];      // assoc by string
    int q21[$];              // queue
    int d21[];               // dynamic
    int f21[8];              // fixed
    int plain21;
    static int ss_enum[sev_e];

    // ---- IN-BODY methods, one CARRIER each, sole body statement ----
    function void ib_inc(sev_e s);            aa_enum[s]++;              endfunction
    function void ib_dec(sev_e s);            aa_enum[s]--;              endfunction
    function void ib_preinc(sev_e s);         ++aa_enum[s];              endfunction
    function void ib_pluseq(sev_e s);         aa_enum[s] += 1;           endfunction
    function void ib_assign(sev_e s);         aa_enum[s] = 1;            endfunction
    function int  ib_ret(sev_e s);            return aa_enum[s];         endfunction
    function void ib_call(sev_e s);           $display("%0d", aa_enum[s]); endfunction
    function void ib_bareinc(int s);          s++;                       endfunction
    function void ib_plainasn(int s);         plain21 = s;               endfunction

    // ---- IN-BODY, `++` in other CARRIERS ----
    function void ib_inc_begin(sev_e s);      begin aa_enum[s]++; end     endfunction
    function void ib_inc_if(sev_e s);         if (plain21) aa_enum[s]++;  endfunction
    function void ib_inc_ifbegin(sev_e s);    if (plain21) begin aa_enum[s]++; end endfunction
    function void ib_inc_two(sev_e s);        aa_enum[s]++; aa_enum[s]++; endfunction
    function void ib_inc_for(sev_e s);        for (int i=0;i<2;i++) aa_enum[s]++; endfunction

    // ---- IN-BODY, `++` sole statement, ARRAY KIND axis ----
    function void ib_inc_int(int s);          aa_int[s]++;               endfunction
    function void ib_inc_str(string s);       aa_str[s]++;               endfunction
    function void ib_inc_q(int s);            q21[s]++;                  endfunction
    function void ib_inc_d(int s);            d21[s]++;                  endfunction
    function void ib_inc_f(int s);            f21[s]++;                  endfunction

    // ---- IN-BODY, DIRECTION axis, `++` sole statement ----
    function void ib_inc_out(output sev_e s); aa_enum[s]++;              endfunction
    function void ib_inc_inout(inout sev_e s);aa_enum[s]++;              endfunction
    function void ib_inc_ref(ref sev_e s);    aa_enum[s]++;              endfunction

    // ---- IN-BODY STATIC / VIRTUAL ----
    static function void ib_inc_static(sev_e s); ss_enum[s]++;           endfunction
    virtual function void ib_inc_virt(sev_e s);  aa_enum[s]++;           endfunction

    // ---- IN-BODY TASK ----
    task ib_inc_task(sev_e s);                aa_enum[s]++;              endtask

    // ---- OUT-OF-BODY prototypes ----
    extern function void oob_inc(sev_e s);
    extern function void oob_inc_if(sev_e s);
    extern function void oob_assign(sev_e s);
    extern function int  oob_ret(sev_e s);

  endclass

  // ---- OUT-OF-BODY definitions (compiled IN THE PACKAGE) ----
  function void c21::oob_inc(sev_e s);        aa_enum[s]++;              endfunction
  function void c21::oob_inc_if(sev_e s);     if (plain21) aa_enum[s]++; endfunction
  function void c21::oob_assign(sev_e s);     aa_enum[s] = 1;            endfunction
  function int  c21::oob_ret(sev_e s);        return aa_enum[s];         endfunction

  // ---- PACKAGE FREE functions ----
  int pk_enum[sev_e];
  int pk_plain;
  function void pf_inc(sev_e s);              pk_enum[s]++;              endfunction
  function void pf_inc_if(sev_e s);           if (pk_plain) pk_enum[s]++; endfunction
  function void pf_assign(sev_e s);           pk_enum[s] = 1;            endfunction
  function int  pf_ret(sev_e s);              return pk_enum[s];         endfunction

endpackage

module m21;
  import gp21::*;
  int md_enum[sev_e];
  int md_plain;
  function void mf_inc(sev_e s);              md_enum[s]++;              endfunction
  function void mf_inc_if(sev_e s);           if (md_plain) md_enum[s]++; endfunction
  function void mf_assign(sev_e s);           md_enum[s] = 1;            endfunction
  function int  mf_ret(sev_e s);              return md_enum[s];         endfunction

  c21 inst21;
  initial begin
    inst21 = new();
    inst21.ib_inc(SEV_A);
    mf_inc(SEV_A);
    pf_inc(SEV_A);
  end
endmodule
