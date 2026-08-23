package pv30i;
  class cv30i;
    int m;
    logic [3:-4] n4;
    extern function int i_d20();
    extern function int i_hff();
    extern function int i_b1111();
    extern function int i_o77();
    extern function int i_und();
    extern function int i_h128();
    extern function int i_b70();
    extern function int i_d128();
    extern function int i_hbig();
    extern function int i_sel();
    extern function int i_selrev();
  endclass
  function int cv30i::i_d20();    return (m == -4'd20);              endfunction
  function int cv30i::i_hff();    return (m == -4'hFF);              endfunction
  function int cv30i::i_b1111();  return (m == -2'b1111);            endfunction
  function int cv30i::i_o77();    return (m == -3'o77);              endfunction
  function int cv30i::i_und();    return (m == -1_000);              endfunction
  function int cv30i::i_h128();   return (m == -128'hFFFFFFFFFFFFFFFFFFFF); endfunction
  function int cv30i::i_b70();    return (m == -70'b1);              endfunction
  function int cv30i::i_d128();   return (m == -128'd5);             endfunction
  function int cv30i::i_hbig();   return (m == -68'h1);              endfunction
  function int cv30i::i_sel();    return n4[-1 : -2];                endfunction
  function int cv30i::i_selrev(); return n4[-1 -: 2];                endfunction
endpackage
