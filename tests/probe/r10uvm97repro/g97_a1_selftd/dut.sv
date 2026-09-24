// r10uvm97 arm a1 — THE HEAD, minimised.  MEASUREMENT-ONLY golden arm.
//
// The self-referential `this_type` idiom inside a PARAMETERIZED class
// (`typedef port97a #(IF) this_type;` inside `class port97a #(type IF)`), with
// TWO live specializations and derived classes writing the INHERITED name as a
// formal — the uvm-1.2 `uvm_port_base` / `uvm_tlm_*_socket::connect` shape,
// which is the cmp head of all seven UVM row-modes at 65468af.
//
// Surelog compiles a parameterized class ONCE, generically, so its class body
// holds exactly ONE `TypeDef` named `this_type` and exactly ONE typespec for
// it, with NO `vpiTypedefAlias`.  slang hands us one `TypeAliasType` per
// SPECIALIZATION, so the class-nested typedef GROUP built by
// § classNestedClassTdGroupNoAnchor54 sees the same Surelog typedef twice and
// aliases the second copy to the first.
package p97a;

  // A SECOND, unrelated `this_type` — the name collision Surelog's
  // ElaborationStep::bindTypedefs_ `specs` map (keyed on the BARE typedef name,
  // first-writer-wins) needs before an INHERITED `this_type` written in a
  // derived class late-binds to a FOREIGN class's object instead of the one
  // slang resolves.  Without it golden and we bind the same object, the
  // already-visited base absorbs the compare (m_visited is keyed on the LHS)
  // and the extra aliased copy is never judged.
  class aaa97a;
    typedef aaa97a this_type;
    this_type m_a;
  endclass

  virtual class port97a #(type IF = int);
    typedef port97a #(IF) this_type;           // <- the head's declaration
    protected this_type m_if;                  // property use site
    local this_type m_by[string];              // associative-array use site
    function void connect(this_type provider);  // formal use site
      m_if = provider;
    endfunction
    function this_type get_if();                // return use site
      return m_if;
    endfunction
  endclass

  // Two CONCRETE derived classes force two specializations of port97a without
  // any class VARIABLE (a package- or module-scope class variable carries its
  // own, unrelated, pre-existing disagreement and would mask this cell).
  class sock1_97a extends port97a #(int);
    function void connect1(this_type provider);   // INHERITED name
      m_if = provider;
    endfunction
  endclass

  class sock2_97a extends port97a #(byte);
    function void connect2(this_type provider);
      m_if = provider;
    endfunction
  endclass

endpackage

module top97a;
endmodule
