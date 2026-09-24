// r10buvm21repro/g21c.sv — the OPERAND-SHAPE arm of the ++ bind law: WHICH
// object inside an increment/decrement statement's operand takes an actual.
// Bases (class property / body local / formal / static) x index (formal /
// local / literal / expression) x depth (1-D / 2-D / member) x prefix/postfix.
package cp21;
  typedef enum { EA, EB } ce21;
  class hh21;
    int h_arr[ce21];
  endclass

  class cc21;
    int prop_arr[ce21];
    int prop_2d[ce21][ce21];
    int prop_sc;
    hh21 hnd;
    static int st_arr[ce21];
    typedef struct packed { int a; int b; } sp21;
    sp21 prop_st;
    sp21 marr[ce21];

    function void s_propidx(ce21 s);        prop_arr[s]++;              endfunction
    function void s_proplit(ce21 s);        prop_arr[EA]++;             endfunction
    function void s_propexpr(int s);        prop_arr[ce21'(s)]++;       endfunction
    function void s_locarr(ce21 s);         int la[ce21]; la[s]++;      endfunction
    function void s_locidx(ce21 s);         int li; prop_arr[s] += li;  endfunction
    function void s_loc_inc(ce21 s);        int lc; lc++;               endfunction
    function void s_formarr(int fa[ce21], ce21 s); fa[s]++;             endfunction
    function void s_static(ce21 s);         st_arr[s]++;                endfunction
    function void s_2d(ce21 s, ce21 t);     prop_2d[s][t]++;            endfunction
    function void s_scalar();               prop_sc++;                  endfunction
    function void s_member();               prop_st.a++;                endfunction
    function void s_pre(ce21 s);            ++prop_arr[s];              endfunction
    function void s_dec(ce21 s);            prop_arr[s]--;              endfunction
    function void s_locidxvar(ce21 s);      ce21 lv; prop_arr[lv]++;    endfunction
    // MEMBER-BASE shapes: the index of a select whose BASE is a member path,
    // and a trailing member on a select (the § lvIncDecCollapseNetSpans7 arm).
    function void s_objidx(ce21 s);         hnd.h_arr[s]++;             endfunction
    function void s_objidx2(ce21 s);        this.prop_arr[s]++;         endfunction
    function void s_memtrail(ce21 s);       marr[s].a++;                endfunction
  endclass
endpackage
