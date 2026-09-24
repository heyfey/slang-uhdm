// r10buvm21repro/g21b.sv — HOME + CARRIER boundary arm for the ++ bind law.
// No module, no import: does the in-body class method still bind under `++`?
// Plus: local variables and class properties under `++`, nested begins,
// loops / case / fork carriers, and classes homed in a module and in $unit.
package hp21;
  typedef enum { A21, B21, C21 } e21;
  class k21;
    int aa[e21];
    int prop21;
    bit [7:0] pvec;
    function void n_inc(e21 s);           aa[s]++;                    endfunction
    function void n_inc_if(e21 s);        if (prop21) aa[s]++;        endfunction
    function void n_inc_begin(e21 s);     begin aa[s]++; end          endfunction
    function void n_inc_bb(e21 s);        begin begin aa[s]++; end end endfunction
    function void n_inc_nb(e21 s);        begin : lbl aa[s]++; end    endfunction
    function void n_inc_while(e21 s);     while (prop21) aa[s]++;     endfunction
    function void n_inc_rep(e21 s);       repeat (2) aa[s]++;         endfunction
    function void n_inc_forever(e21 s);   forever aa[s]++;            endfunction
    function void n_inc_case(e21 s);      case (prop21) 0: aa[s]++; endcase endfunction
    function void n_inc_do(e21 s);        do aa[s]++; while (prop21); endfunction
    function void n_inc_expr(e21 s);      aa[s]++; prop21++;          endfunction
    function void n_inc_locvar(e21 s);    int lv; lv++; aa[s]++;      endfunction
    function void n_inc_idxexpr(int s);   aa[e21'(s+1)]++;            endfunction
    function void n_inc_this(e21 s);      this.aa[s]++;               endfunction
    function void n_inc_two_names(e21 s, int t); aa[s]++; prop21 += t; endfunction
    task n_inc_fork(e21 s);               fork aa[s]++; join          endtask
    function void n_dec_pre(e21 s);       --aa[s];                    endfunction
    function void n_inc_nbl(e21 s);       begin : nb int nbl; nbl++; aa[s]++; end endfunction
    function void n_inc_partsel(int s);   pvec[s+:2]++;               endfunction
    function void n_inc_exprstmt(e21 s);  int r; r = aa[s]++;         endfunction
  endclass
endpackage

module mh21;
  typedef enum { MA, MB } me21;
  class mk21;
    int maa[me21];
    int mprop;
    function void m_inc(me21 s);          maa[s]++;                   endfunction
    function void m_inc_if(me21 s);       if (mprop) maa[s]++;        endfunction
  endclass
endmodule

typedef enum { UA, UB } ue21;
int u_free_arr[2];
function void uf_inc(int s);              u_free_arr[s]++;            endfunction
function void uf_inc_loc(int s);          int ul; ul++;               endfunction

class uk21;
  int uaa[ue21];
  int uprop;
  function void u_inc(ue21 s);            uaa[s]++;                   endfunction
  function void u_inc_if(ue21 s);         if (uprop) uaa[s]++;        endfunction
endclass
