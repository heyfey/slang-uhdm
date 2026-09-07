// r10uvm194 arm B — SELECT KIND x RETURN TYPE, every cell inside an OUT-OF-BODY
// class method (the law's own home).  Surelog's `uhdmbegin` late-binding arm
// tests only `lhs->VpiName() == name` and skips a `ref_obj`/`ref_var` lhs, so
// the SELECT KIND should not matter and a WHOLE write should not answer — this
// arm scores that rather than assuming it.
package b194_src;
  class B194;
    extern function string        b_bit();
    extern function bit [15:0]    b_part();
    extern function bit [15:0]    b_ipart();
    extern function int           b_whole();
    extern function string        b_two();
    extern function string        b_local();
  endclass

  // bit-select on a STRING return (the corpus shape: uvm_packer::unpack_string)
  function string B194::b_bit();
    int i; i=0;
    b_bit = {b_bit," "};
    b_bit[i] = 8'h41;
  endfunction

  // PART-select on a packed-vector return
  function bit [15:0] B194::b_part();
    int i; i=0;
    b_part = 16'h0;
    b_part[7:4] = 4'h5;
  endfunction

  // INDEXED part-select on a packed-vector return
  function bit [15:0] B194::b_ipart();
    int i; i=2;
    b_ipart = 16'h0;
    b_ipart[i +: 4] = 4'h6;
  endfunction

  // WHOLE write only — no select at all: the `ref_obj` lhs Surelog SKIPS.
  function int B194::b_whole();
    int i; i=0;
    b_whole = 3;
    b_whole = b_whole + 1;
  endfunction

  // TWO selects: Surelog's scan takes the FIRST answering statement.
  function string B194::b_two();
    int i; i=0;
    b_two = {b_two," "};
    b_two[i] = 8'h41;
    b_two[i] = 8'h42;
  endfunction

  // a select on a LOCAL of the same shape: the return name must be untouched.
  function string B194::b_local();
    int i; string t;
    i=0; t = "xy";
    t[i] = 8'h41;
    b_local = {b_local,t};
  endfunction
endpackage

module b194_top;
  import b194_src::*;
  B194 h;
  string s1, s5, s6;
  bit [15:0] v2, v3;
  int n4;
  initial begin
    h = new();
    s1 = h.b_bit();
    v2 = h.b_part();
    v3 = h.b_ipart();
    n4 = h.b_whole();
    s5 = h.b_two();
    s6 = h.b_local();
  end
endmodule
