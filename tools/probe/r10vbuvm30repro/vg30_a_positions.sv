package pv30a;
  typedef int ia_t [2];
  class cv30a;
    int m;
    logic [15:-8] v;
    int q[$];
    int arr[];
    function int meth(int a); return a + m; endfunction
    extern function int a_ipsel();
    extern function int a_ipsel2();
    extern function int a_stream();
    extern function ia_t a_appat();
    extern function int a_named();
    extern function int a_with();
    extern function int a_terncond();
    extern function int a_castcmp();
    extern function int a_concat_in_sys();
    extern function int a_chain();
    extern function int a_qidx();
    extern function int a_inside();
    extern function int a_two_deep();
  endclass
  function int cv30a::a_ipsel();       return v[-1 +: 2];                endfunction
  function int cv30a::a_ipsel2();      return v[-1 : -2];                endfunction
  function int cv30a::a_stream();      return {>>{-1}};                  endfunction
  function ia_t cv30a::a_appat();      return '{-1, 2};                  endfunction
  function int cv30a::a_named();       return this.meth(.a(-1));         endfunction
  function int cv30a::a_with();        return q.sum() with (item + -1);  endfunction
  function int cv30a::a_terncond();    return (-1) ? 1 : 2;              endfunction
  function int cv30a::a_castcmp();     return (m == int'(-1));           endfunction
  function int cv30a::a_concat_in_sys();return $countones({-1, 1});      endfunction
  function int cv30a::a_chain();       return this.meth(-1) + this.meth(-2); endfunction
  function int cv30a::a_qidx();        return q[-1];                     endfunction
  function int cv30a::a_inside();      return (m inside {-1, 2});        endfunction
  function int cv30a::a_two_deep();    return ((((m == -1)))) ;          endfunction
endpackage
