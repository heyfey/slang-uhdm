// r10v142 verifier arm E — FLAG LEAK and the BUILT-IN fences.
// The gate is a MEMBER flag held across the whole recursive makeTypespec call,
// so a class handle reached THROUGH another type (a struct member, an array
// element typespec) is the leak this arm looks for.  It also re-reads the two
// built-in fences (§ builtinClassTsLinksBuiltinFileDefn7, both halves) under
// the PAREN-LESS header, where the new gate is the one that could break them.
package pv5142;
  class Kv5142;
    int f;
  endclass
  typedef struct {
    Kv5142 sm;
    int    si;
  } sv5142;
  typedef Kv5142 tv5142;

  class Hv5142;
    function void htf;               // PAREN-LESS: TF-ITEM
      sv5142  h_struct;              // a class handle THROUGH a struct member
      Kv5142  h_direct;
      static Kv5142 h_static;
    endfunction
    function void hbl();             // paren'd: BLOCK
      sv5142  hb_struct;
      Kv5142  hb_direct;
      static Kv5142 hb_static;
    endfunction
    task hfork;
      Kv5142 hf_out;
      fork
        begin
          Kv5142 hf_in;
        end
      join_none
    endtask
  endclass

  function void ptf5142;             // PAREN-LESS package free function
    sv5142    p_struct;
    Kv5142    p_direct;
    static Kv5142 p_static;
    tv5142    p_td;
  endfunction
  function void pbl5142();
    sv5142    pb_struct;
    Kv5142    pb_direct;
    static Kv5142 pb_static;
    tv5142    pb_td;
  endfunction
endpackage
