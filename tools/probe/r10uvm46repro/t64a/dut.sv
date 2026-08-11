// r10uvm46 arm t64a — WHICH FEATURE LOSES THE NAME?
//
// BuildUVMPkg's whole remaining residue is ONE object: golden holds an
// EMPTY-NAMED, ZERO-FORMAL function where the source says
//   uvm_pkg.sv:75228  local function automatic int unsigned ceil(int unsigned a,
//                                                                int unsigned b);
// (class uvm_reg_map).  ONE object, FOUR metrics — LSTOTAL 2, r10uvm23m tf=2,
// IOTOTAL 2, IOTOTAL2 3 — all confirmed to be this function.
//
// The handoff names two candidate distinguishers, `local` and the TWO-TOKEN
// return type `int unsigned`.  A single witness cannot separate them, so this
// arm crosses them and adds the neighbouring spellings: `automatic` or not,
// class scope or package scope, function or task, and the other two-token type
// spellings (`bit signed`, `logic unsigned`, `byte unsigned`).  Whatever golden
// leaves unnamed here IS the rule.
package p64;

  class c64;
    // (1) all three features, exactly uvm_pkg's spelling
    local function automatic int unsigned f_loc_auto_2tok(int unsigned a, int unsigned b);
      int r = a / b;
      return r;
    endfunction
    // (2) two-token return type, NOT local
    function automatic int unsigned f_auto_2tok(int unsigned a, int unsigned b);
      int r = a / b;
      return r;
    endfunction
    // (3) local + automatic, ONE-token return type
    local function automatic int f_loc_auto_1tok(int unsigned a, int unsigned b);
      int r = a / b;
      return r;
    endfunction
    // (4) local + two-token, NO automatic
    local function int unsigned f_loc_2tok(int unsigned a, int unsigned b);
      int r = a / b;
      return r;
    endfunction
    // (5) two-token only, no local, no automatic
    function int unsigned f_2tok(int unsigned a);
      return a;
    endfunction
    // (6) local only, one-token
    local function int f_loc_1tok(int unsigned a);
      return a;
    endfunction
    // (7) the other two-token spellings
    local function automatic bit signed f_bit_signed(int a);
      return a[0];
    endfunction
    local function automatic byte unsigned f_byte_unsigned(int a);
      return a[7:0];
    endfunction
    local function automatic logic unsigned f_logic_unsigned(int a);
      return a[0];
    endfunction
    // (8) a TASK with local + automatic (no return type at all)
    local task automatic t_loc_auto(int unsigned a);
      $display("%0d", a);
    endtask
  endclass

  // (9) the same spelling at PACKAGE scope, where `local` is illegal
  function automatic int unsigned g_auto_2tok(int unsigned a, int unsigned b);
    int r = a / b;
    return r;
  endfunction

  function automatic int g_auto_1tok(int unsigned a);
    return a;
  endfunction

endpackage

module t64a;
  initial begin
    p64::c64 h;
    h = new();
  end
endmodule
