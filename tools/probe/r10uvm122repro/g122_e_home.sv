// r10uvm122 arm e — the HOME face: which enclosing construct owns the body,
// and which declaration the name resolves to.  Every cell writes a select in
// an inner begin and reads the bare name in the same begin.
package p122e;
  int pkgv;
  class c122e;
    int prop;
    bit [31:0] pv;
    // e1 — a class method reading a CLASS PROPERTY
    function int e1_prop (int unsigned s);
      if (s) begin
        pv ^= 3;
        pv[0] = 1;
      end
      return pv;
    endfunction
    // e2 — a class method reading a PACKAGE variable
    function int e2_pkg (int unsigned s);
      if (s) begin
        pkgv ^= 3;
        pkgv[0] = 1;
      end
      return pkgv;
    endfunction
    // e3 — a class method reading its OWN LOCAL
    function int e3_local (int unsigned s);
      bit [31:0] lv;
      lv = 1;
      if (s) begin
        lv ^= 3;
        lv[0] = 1;
      end
      return lv;
    endfunction
  endclass
  // e4 — an OUT-OF-BODY class method reading its own local
  class c122e2;
    extern function int e4_oob (int unsigned s);
  endclass
  function int c122e2::e4_oob (int unsigned s);
    bit [31:0] ov;
    ov = 1;
    if (s) begin
      ov ^= 3;
      ov[0] = 1;
    end
    return ov;
  endfunction
endpackage

module m122e;
  bit  [31:0] mnet;      // a module-scope VECTOR
  int         mint;      // a module-scope INT
  int         marr [0:3];
  // e5 — an INITIAL block over a module-scope vector
  initial begin
    mnet = 1;
    if (mnet[1]) begin
      mnet ^= 3;
      mnet[0] = 1;
    end
  end
  // e6 — an ALWAYS_COMB over a module-scope INT
  always_comb begin
    mint = 1;
    if (mint) begin
      mint = mint + 1;
      mint[0] = 1;
    end
  end
  // e7 — a NONBLOCKING module-scope write
  always @(mnet) begin
    if (mnet[2]) begin
      mnet ^= 3;
      mnet[1] <= 1;
    end
  end
  // e8 — a module FUNCTION local
  function int e8_fnlocal (int unsigned s);
    bit [31:0] fv;
    fv = 1;
    if (s) begin
      fv ^= 3;
      fv[0] = 1;
    end
    return fv;
  endfunction
  // e9 — a module-scope UNPACKED ARRAY written by element
  initial begin
    if (mint) begin
      marr = '{default:0};
      marr[0] = 1;
    end
  end
  // e10 — a module function reading a MODULE-SCOPE variable
  function int e10_modvar (int unsigned s);
    if (s) begin
      mint ^= 3;
      mint[0] = 1;
    end
    return mint;
  endfunction
endmodule

// e11 — a $unit-scope function local (the unitSubNoBind9 home)
function automatic int e11_unit (int unsigned s);
  bit [31:0] uv;
  uv = 1;
  if (s) begin
    uv ^= 3;
    uv[0] = 1;
  end
  return uv;
endfunction

interface i122e;
  int iv;
  // e12 — an interface task local
  task e12_iftask (int unsigned s);
    bit [31:0] tv;
    tv = 1;
    if (s) begin
      tv ^= 3;
      tv[0] = 1;
    end
  endtask
endinterface
