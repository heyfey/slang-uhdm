package pv30g;
  class cv30g;
    int m;
    int arr[];
    extern function int g_notret_cmp(int a);
    extern function int g_ret_deepblock();
    extern function int g_ret_forloop();
    extern function int g_ret_case(int a);
    extern function int g_two_returns(int a);
  endclass
  function int cv30g::g_notret_cmp(int a);
    int t;
    t = (a == -1);
    return t;
  endfunction
  function int cv30g::g_ret_deepblock();
    begin : bb
      return (m == -1);
    end
  endfunction
  function int cv30g::g_ret_forloop();
    for (int i = 0; i < 2; i++) return (m == -1);
    return (m == -2);
  endfunction
  function int cv30g::g_ret_case(int a);
    case (a)
      1: return (m == -1);
      default: return (m == -2);
    endcase
  endfunction
  function int cv30g::g_two_returns(int a);
    if (a) return (m == -1);
    return (m == -2);
  endfunction
endpackage
