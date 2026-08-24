// r10uvm122 arm a — the OWNER face.  Every cell writes a bit-select of a name
// in an INNER begin and reads the bare name in the SAME inner begin.
// Golden's answer is read off Surelog; ours off both binaries.
package p122a;

  int pkgvar;

  // a1 — a FUNCTION LOCAL (the head's own shape)
  function int a1_fnlocal (int unsigned s);
    bit [31:0] v;
    v = 1;
    if (s) begin
      v ^= 3;                 // cell a1r
      v[0] = 1;               // the select
    end
    return v;
  endfunction

  // a2 — a TASK LOCAL
  task a2_tasklocal (int unsigned s);
    bit [31:0] v;
    v = 1;
    if (s) begin
      v ^= 3;                 // cell a2r
      v[0] = 1;
    end
  endtask

  // a3 — a FUNCTION FORMAL (io_decl)
  function int a3_formal (int unsigned s, bit [31:0] v);
    if (s) begin
      v ^= 3;                 // cell a3r
      v[0] = 1;
    end
    return v;
  endfunction

  // a4 — an AUTOMATIC function local
  function automatic int a4_auto (int unsigned s);
    bit [31:0] v;
    v = 1;
    if (s) begin
      v ^= 3;                 // cell a4r
      v[0] = 1;
    end
    return v;
  endfunction

  // a5 — a PACKAGE variable read from a free function
  function int a5_pkgvar (int unsigned s);
    if (s) begin
      pkgvar ^= 3;            // cell a5r
      pkgvar[0] = 1;
    end
    return pkgvar;
  endfunction

  // a6 — an INT (non-vector) local: a bit-select of an int
  function int a6_intlocal (int unsigned s);
    int v;
    v = 1;
    if (s) begin
      v ^= 3;                 // cell a6r
      v[0] = 1;
    end
    return v;
  endfunction

  // a7 — a LOGIC local
  function int a7_logiclocal (int unsigned s);
    logic [15:0] v;
    v = 1;
    if (s) begin
      v ^= 3;                 // cell a7r
      v[0] = 1;
    end
    return v;
  endfunction

  // a8 — an UNPACKED ARRAY local (element select, not a bit select)
  function int a8_arrlocal (int unsigned s);
    int v [0:3];
    if (s) begin
      v = '{default:0};       // cell a8r  (whole write, ref_obj lhs)
      v[0] = 1;
    end
    return v[1];
  endfunction

  // a9 — a CLASS PROPERTY read from a method
  class c122a;
    bit [31:0] v;
    function int m (int unsigned s);
      if (s) begin
        v ^= 3;               // cell a9r
        v[0] = 1;
      end
      return v;
    endfunction
  endclass

  // a10 — the RETURN NAME itself
  function int unsigned a10_retname (int unsigned s);
    if (s) begin
      a10_retname ^= 3;       // cell a10r
      a10_retname[0] = 1;
    end
  endfunction
endpackage
